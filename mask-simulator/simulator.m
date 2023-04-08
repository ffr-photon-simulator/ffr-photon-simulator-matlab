tic;
%clear all; % clear workspace
% Add the configs to the path
%cwd = pwd % current working directory
%configDir = cwd + "mask-simulator/ffrConfigs"
%addpath(configDir)
% Generate the config
%config_3M1860;
config_3M9210;

% Make the FFR
ffr = FFR(ffrConfig);

% Make a RayTracer
rt = RayTracer(ffr);

% Generate the incoming photons.
% First, check if xStart is set in the Config struct. If not, set their values here.
% Defaults to 1/4 the FFR length, centered about 0, so 1/8 on either side.
if isempty(xStart)
  xStart = -ffrConfig.length / 8;
  xEnd = -xStart;
end
outerBound = ffr.ffrBounds.outerBound; % the boundary object, not the value
[initialPhotons, nPhotons] = makeInitialPhotons(xStart, xEnd, Defaults.initialSeparation, outerBound, Defaults.initialXStep, Defaults.outerToInnerYStep);

% Ray trace
Defaults.debugMessage("Starting ray tracing...", 0);
[photonPaths, boundInfo] = rt.rayTrace(ffr, initialPhotons);
Defaults.debugMessage("Finished ray tracing.", 0);

% Calculate and store photon crossing information.
% Each photon that enters an FFR Layer is considered available for decontamination.
% This is because the photon's energy is independent of how many times it reflects off of fibers.
% Because the photon's path length (distance traveled) increases if it reflects back into a layer
% (toOuter direction on inner bound), we need to count it as available for decontamination.
% To track every photon entering a layer, we total the toInner count for the upper bound and the
% toOuter count for the inner bound.
ffrLayers = ffr.ffrLayers;
interiorBounds = ffr.boundaries.interiorBounds;
ffrBounds = ffr.boundaries.ffrBounds;
for i = 1:ffr.nLayers
  layer = ffrLayers(i);
  if i == 1 % inner, exterior layer
    %layer.nPhotonsOut = ffrBounds.innerBound.count;
    layer.nPhotonsIn  = interiorBounds(i).toInner;
  elseif i == ffr.nLayers
    %layer.nPhotonsOut = interiorBounds(i - 1).toInner;
    layer.nPhotonsIn  = interiorBounds(i - 1).toOuter + nPhotons;
  else
    layer.nPhotonsIn  = interiorBounds(i).toInner + interiorBounds(i-1).toOuter;
    %layer.nPhotonsOut = interiorBounds(i - 1).toInner;
  end
end

Defaults.debugMessage("\nPHOTON PERCENTAGES", 0);

% Calculate photon percentage in each layer.
for i = 1:ffr.nLayers
  layer = ffrLayers(i);
  Defaults.debugMessage("FFR Layer " + i, 0);
  layer.showPhotonPercentage(nPhotons);
end

% Graph FFR fibers and photon paths
clf; % clear current plot
ax = axes;
hold on; % don't overwrite plot
axis equal; % make x and y axis scale the same
% Plot fiber centers
%plot(ax, ffr.fiberData(:,1), ffr.fiberData(:,2), Defaults.fiberCenterStyle,'MarkerSize', Defaults.fiberCenterWeight);

% Plot fiber circles
ffrFiberData = ffr.fiberData;
for i = 1:size(ffrFiberData, 1) % number of rows is the number of fibers
  data = ffrFiberData(i,:);
  x = data(1);
  y = data(2);
  r = data(3);
  theta = linspace(0,2*pi,100);
  xcoords = r * cos(theta) + x;
  ycoords = r * sin(theta) + y;
  plot(ax, xcoords, ycoords, Defaults.fiberCircleStyle,'MarkerSize',Defaults.fiberCircleWeight);
end

% Plot photon paths
plot(ax, photonPaths(:,1), photonPaths(:,2), Defaults.photonPathStyle,'MarkerSize', Defaults.photonPathWeight);

% Plot bounds and print crossing info
disp("")
ffrBounds = ffr.ffrBounds;
fields = fieldnames(ffrBounds);
for i = 1:numel(fields)
  bound = ffrBounds.(fields{i});
  bound.plot(ax);
  bound.printCrossingInfo();
end

Debug.newline();

interiorBounds = ffr.boundaries.interiorBounds;
for i = 1:size(interiorBounds)
  bound = interiorBounds(i);
  bound.plot(ax);
  bound.printCrossingInfo();
end

% Set plot limits
ax.XLim = [ffrBounds.leftBound.bound ffrBounds.rightBound.bound];
ax.YLim = [ffrBounds.innerBound.bound ffrBounds.outerBound.bound];

Debug.newLine();

toc

time = datetime('Now','Format','HH-mm-ss');
photonsInToCSV(ffrLayers, ffr.nLayers, time, ffrConfig, nPhotons);
figureToSVG(ffrConfig, nPhotons, ax, time);
configToMAT(ffrConfig, time, nPhotons);

% FUNCTIONS
function [photons, nPhotons] = makeInitialPhotons(xStart, xEnd, separation, outerBoundary, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to the value of the outer boundary. The initial photons are
  % separated by the value of the "separation" variable.
  nPhotons = fix((xEnd-xStart) / separation); % use 'fix' to round down to nearest integer
  Defaults.debugMessage("Num photons: " + nPhotons, 0);
  photons = [];
  bound = outerBoundary.bound;
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, bound, initialXStep, outerToInnerYStep);
    %nextPhoton = Photon(xStart + m*separation, Defaults.nQLayers * Defaults.qlWidth, initialXStep, outerToInnerYStep);
    photons = [photons; nextPhoton];
  end
end

function photonsInToCSV(ffrLayers, nLayers, time, ffrConfig, nPhotons)
  % Write a 2 x nLayers array to a csv file.
  data = zeros(nLayers, 2);
  data(:,1) = 9:-1:1;
  data(:, 2) = [ffrLayers.nPhotonsIn];

  csvdir = sprintf("results/data");
  model = ffrConfig.model;
  dim = sprintf("%dx%d", ffrConfig.lengthI, ffrConfig.widthI);
  name = sprintf("%dph_%dlayer", nPhotons, ffrConfig.nLayers);
  ext = "csv";
  filepath = sprintf("%s/%s/%s/%s_%s.%s", csvdir, model, dim, name, time, ext);
  Debug.msgWithItem("csv path", filepath, 0);
  writematrix(data, filepath, 'Delimiter', 'comma');
end

function configToMAT(ffrConfig, time, nPhotons)
  % Save the ffrConfig struct as a .mat file. It is hard to save it as anything
  % else because it is a nested struct with object arrays. Given that we store
  % the config as a backup, it is reasonable to request the user to open Matlab
  % to view the config.
  %
  % Run this command to get the ffrConfig struct: clear('ffrConfig'); load('<config_name>.mat')

  matdir = sprintf("results/configs");
  model = ffrConfig.model;
  dim = sprintf("%dx%d", ffrConfig.lengthI, ffrConfig.widthI);
  name = sprintf("%dph_%dlayer", nPhotons, ffrConfig.nLayers);
  ext = "mat";
  filepath = sprintf("%s/%s/%s/%s_%s.%s", matdir, model, dim, name, time, ext);
  Debug.msgWithItem("mat path", filepath, 0);
  save(filepath, 'ffrConfig')
end

function figureToSVG(ffrConfig, nPhotons, ax, time)
  % Use export_fig (https://github.com/altmany/export_fig) to generate a high-quality
  % SVG of the plot. A directory variable does NOT include a trailing backlash.
  %
  % Top level dirs: data, images, and configs.
  % <tld>/<model>/<length>x<width>/<nPhotons>ph_<nLayers>layer-<time>.ext

  svgdir = sprintf("results/images");
  model = ffrConfig.model;
  dim = sprintf("%dx%d", ffrConfig.lengthI, ffrConfig.widthI);
  name = sprintf("%dph_%dlayer", nPhotons, ffrConfig.nLayers);
  ext = "svg";
  filepath = sprintf("%s/%s/%s/%s_%s.%s", svgdir, model, dim, name, time, ext);
  Debug.msgWithItem("svg path", filepath, 0);
  export_fig(filepath, ax)
end
