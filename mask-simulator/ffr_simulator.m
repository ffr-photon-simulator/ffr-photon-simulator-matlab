%%% The "main" function or script to run the simulator.

% This script defines the variables necessary to run ray tracing simulations
% on groups of Layers. A ray tracing method is called, and the output is displayed.

%%% USER CONFIGURATION
% Initial photon multipliers
% Change the x-separation between each initial photon:
%  >1 decreases the number of photons
%  <1 increases the number of photons
separationMultiplier = 100;
% Change the length of the initial photons' y step:
%  >1 increases the y step
%  <1 decreases the y step
yStepMultiplier = 1;

% Layers
nLayers = 2; % the number of layers

%%% CONSTANTS
% Initial photons
initialXStep = 0;
% Define two initial y steps, one for ray tracing from the outer layer to
% the inner layer of the FFR, the other for the opposite direction. This
% is the only change necessary to ray trace in the opposite direction.
outerToInnerYStep = -(Photon.WAVELENGTH/2)*yStepMultiplier;
innerToOuterYStep = -outerToInnerYStep;
% The x-separation between each initial photon.
separation = abs(outerToInnerYStep)*separationMultiplier;

% Layer parameter arrays. The value at index i in these arrays
% will be the value supplied to the ith layer. Thus each array
% must be the same length.
lengths = [10, 10]; % multiply by 10 microns
widths  = [10, 10]; % multiply by 10 microns
minRadii  = [0, 0]; % will be overridden
maxRadii  = [0, 0]; % will be overridden
densities = [0, 0]; % density per layer, will be overridden

%%% GENERATION
% Make a cell array to the store layers.
layersCell = cell(1,nLayers);
for i = 1:nLayers
  layersCell{i} = Layer(lengths(i), widths(i), minRadii(i), maxRadii(i), densities(i));
end

% Make a plain array from the cell array.
layersArray = [layersCell{:}];

% Make an array of the initial photons.
initialPhotons = makeInitialPhotons(-3*BubblebathFiberLattice.LATTICE_I, 3*BubblebathFiberLattice.LATTICE_I, separation, layersArray(1), initialXStep, outerToInnerYStep);
%disp(initialPhotons)

% Make the boundary map.
boundNames = {'inner','outer','left','right'};
boundArrays = {[],[],[],[]};
iterativeLeftRightBoundsMap = containers.Map(boundNames, boundArrays);

%%% RAY TRACING
transmittedToInteriorLayer = iterativeRayTrace(initialPhotons, layersArray, iterativeLeftRightBoundsMap);

%%% OUTPUTS
disp("Number of photons that traversed each layer to reach and then escape the interior layer: " + size(transmittedToInteriorLayer,1))

%%% Helper functions
function photons = makeInitialPhotons(xStart, xEnd, separation, exteriorLayer, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to half the first layer's width.
  nPhotons = (xEnd-xStart)/separation;
  disp("Num photons: " + nPhotons)
  photons = [];
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, exteriorLayer.latticeWidth/2, initialXStep, outerToInnerYStep);
    photons = [photons; nextPhoton];
  end
end

function transmittedPhotons = prepareIncomingPhotons(nextLayer, transmittedPhotons)
  nTransmittedPhotons = size(transmittedPhotons, 1);
  for i = 1:nTransmittedPhotons
    transmittedPhotons(i).setY(nextLayer.latticeWidth/2);
  end
end

function iterativeSummary(layerNum, photonsAtBoundsMap)
    transmittedPhotons = photonsAtBoundsMap('inner');
    reflectedBack = photonsAtBoundsMap('outer');
    reflectedLeft = photonsAtBoundsMap('left');
    reflectedRight = photonsAtBoundsMap('right');
    disp("=============================================================")
    disp("Layer " + layerNum + " summary. List of photons reflected: ")
    disp("> through: " + size(transmittedPhotons,1) + " (transmitted)")
    disp(">    back: " + size(reflectedBack,1))
    disp(">    left: " + size(reflectedLeft,1))
    disp(">   right: " + size(reflectedRight,1))
    disp("=============================================================")
end

function transmittedToInterior = iterativeRayTrace(initialPhotons, layersArray, leftRightAtBoundsMap)
  % Iterate and ray trace each layer in a LayerStack.
  % The photons transmitted through one layer become
  % the incoming photons for the next layer.
  rayTracer = RayTracer();
  incomingPhotons = initialPhotons;
  for i = 1:size(layersArray,2)
    layer = layersArray(i);
    % Ray trace and receive a map of {boundary -> [photons]}.
    photonsAtBoundsMap = rayTracer.rayTrace(layer, incomingPhotons); 
    % Store the necessary photon arrays.
    transmittedPhotons = photonsAtBoundsMap('inner');
    leftRightAtBoundsMap('left')  = [leftRightAtBoundsMap('left');  photonsAtBoundsMap('left')];
    leftRightAtBoundsMap('right') = [leftRightAtBoundsMap('right'); photonsAtBoundsMap('right')];
    % Display results for this layer.
    iterativeSummary(i, photonsAtBoundsMap);
    if i < size(layersArray,2)
      incomingPhotons = prepareIncomingPhotons(layersArray(i+1), transmittedPhotons);
    end
  end
  transmittedToInterior = transmittedPhotons;
end

function singleRayTrace()
  % Ray trace a single layer. Shows a summary of the
  % photons that arrived at each boundary.
end
