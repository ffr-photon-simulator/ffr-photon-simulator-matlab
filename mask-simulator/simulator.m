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
disp("Starting ray tracing.")
[photonPaths, boundInfo] = rt.rayTrace(ffr, initialPhotons);

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

% Plot bounds
ffrBounds = ffr.ffrBounds;
fields = fieldnames(ffrBounds);
for i = 1:numel(fields)
  bound = ffrBounds.(fields{i});
  bound.plot(ax);
end

interiorBounds = ffr.boundaries.interiorBounds;
for i = 1:size(interiorBounds)
  bound = interiorBounds(i);
  Defaults.debugMessage("Interior bound at: " + string(bound.bound), 0);
  bound.plot(ax);
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
