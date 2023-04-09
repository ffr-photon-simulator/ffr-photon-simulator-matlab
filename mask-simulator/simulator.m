plotbool = true;
%clear all; % clear workspace

%cwd = pwd % current working directory
%configDir = cwd + "mask-simulator/ffrConfigs"
%addpath(configDir)
%config_3M1860;
config_3M9210;

ffr = FFR(ffrConfig);

rt = RayTracer(ffr);

if isempty(xStart)
  xStart = -ffrConfig.length / 8;
  xEnd = -xStart;
end
outerBound = ffr.ffrBounds.outerBound; % the boundary object, not the value
[initialPhotons, nPhotons] = makeInitialPhotons(xStart, xEnd, Defaults.initialSeparation, outerBound, Defaults.initialXStep, Defaults.outerToInnerYStep);

Defaults.debugMessage("Starting ray tracing...", 0);
[photonPaths, boundInfo] = rt.rayTrace(ffr, initialPhotons);
Defaults.debugMessage("Finished ray tracing.", 0);

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
for i = 1:ffr.nLayers
  layer = ffrLayers(i);
  Defaults.debugMessage("FFR Layer " + i, 0);
  layer.showPhotonPercentage(nPhotons);
end

if plotbool == true
  clf; % clear current plot
  ax = axes;
  axis equal; % make x and y axis scale the same
  hold on; % don't overwrite plot with each subsequent addition

  %plot(ax, ffr.fiberData(:,1), ffr.fiberData(:,2), Defaults.fiberCenterStyle,'MarkerSize', Defaults.fiberCenterWeight);

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

  plot(ax, photonPaths(:,1), photonPaths(:,2), Defaults.photonPathStyle,'MarkerSize', Defaults.photonPathWeight);

  disp("")
  ffrBounds = ffr.ffrBounds;
  fields = fieldnames(ffrBounds);
  for i = 1:numel(fields)
    bound = ffrBounds.(fields{i});
    bound.plot(ax);
    bound.printCrossingInfo();
  end
  %plotFFRBounds(ffrBounds, ax);

  Debug.newline();

  interiorBounds = ffr.boundaries.interiorBounds;
  for i = 1:size(interiorBounds)
    bound = interiorBounds(i);
    bound.plot(ax);
    bound.printCrossingInfo();
  end

  ax.XLim = [ffrBounds.leftBound.bound ffrBounds.rightBound.bound];
  ax.YLim = [ffrBounds.innerBound.bound ffrBounds.outerBound.bound];

end
Debug.newline();

time = datetime('Now','Format','HH-mm-ss');
photonsInToCSV(ffrLayers, ffr.nLayers, time, ffrConfig, nPhotons);
figureToSVG(ffrConfig, nPhotons, ax, time);
configToMAT(ffrConfig, time, nPhotons);

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
  writematrix(data, filepath, 'Delimiter', 'comma')
end

function configToMAT(ffrConfig, time, nPhotons)
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
  svgdir = sprintf("results/images");
  model = ffrConfig.model;
  dim = sprintf("%dx%d", ffrConfig.lengthI, ffrConfig.widthI);
  name = sprintf("%dph_%dlayer", nPhotons, ffrConfig.nLayers);
  ext = "svg";
  filepath = sprintf("%s/%s/%s/%s_%s.%s", svgdir, model, dim, name, time, ext);
  Debug.msgWithItem("svg path", filepath, 0);
  export_fig(filepath, ax, '-r600')
end

function plotFFRBounds(ffrBounds, ax)
  left = ffrBounds.leftBound.bound;
  right = ffrBounds.rightBound.bound
  outer = ffrBounds.outerBound.bound;
  inner = 0;
  % Inner
  plot(ax, [left 0], [right 0]);
  %plot(ax, [left, 0], [right, 0], inner, 'LineWidth', Defaults.ffrBoundWeight);
  % Outer
  %plot(ax, [left, outer], [right, outer], outer, 'LineWidth', Defaults.ffrBoundWeight);
  % Left and right bounds
  %plot(ax, [left, 0], [left, outer], left, 'LineWidth', Defaults.ffrBoundWeight);
  %plot(ax, [right, 0], [right, inner], right, 'LineWidth', Defaults.ffrBoundWeight);
end
