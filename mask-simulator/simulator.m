%simulator_handler
%% Simulates an FFR.
% Generate the config
%defaultConfig
%config
n95config


% Make the FFR
ffr = FFR(ffrConfig);

% Make a RayTracer
rt = RayTracer();

% Generate the incoming photons
xStart = -Defaults.nQuadrants * Defaults.qLength / 2;
xEnd = -xStart;
outerBound = ffr.ffrBounds.outerBound;
initialPhotons = makeInitialPhotons(xStart, xEnd, Defaults.initialSeparation, outerBound, Defaults.initialXStep, Defaults.outerToInnerYStep);

% Ray trace
Defaults.debugMessage("Starting ray tracing", 0);
[photonPaths, boundInfo] = rt.rayTrace(ffr, initialPhotons);

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
    layer.nPhotonsIn  = interiorBounds(i - 1).toOuter + 3;
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
plot(ax, ffr.fiberData(:,1), ffr.fiberData(:,2), Defaults.fiberCenterStyle,'MarkerSize', Defaults.fiberCenterWeight);

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

disp("")

interiorBounds = ffr.boundaries.interiorBounds;
for i = 1:size(interiorBounds)
  bound = interiorBounds(i);
  Defaults.debugMessage("Interior bound at: " + string(bound.bound), 0);
  bound.plot(ax);
  bound.printCrossingInfo();
end

% Set plot limits
ax.XLim = [ffrBounds.leftBound.bound ffrBounds.rightBound.bound];
ax.YLim = [ffrBounds.innerBound.bound ffrBounds.outerBound.bound];

fprintf("\n")

% FUNCTIONS
function photons = makeInitialPhotons(xStart, xEnd, separation, outerBoundary, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to the value of the outer boundary. The initial photons are
  % separated by the value of the "separation" variable.
  nPhotons = (xEnd-xStart) / separation;
  disp("Num photons: " + nPhotons)
  photons = [];
  bound = outerBoundary.bound;
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, bound, initialXStep, outerToInnerYStep);
    %nextPhoton = Photon(xStart + m*separation, Defaults.nQLayers * Defaults.qlWidth, initialXStep, outerToInnerYStep);
    photons = [photons; nextPhoton];
  end
end
