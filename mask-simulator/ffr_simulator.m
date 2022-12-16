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
nLayers = 3; % the number of layers

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
lengths = [10, 10, 10]; % multiply by 10 microns
widths  = [10, 10, 10]; % multiply by 10 microns
minRadii  = [0, 0, 0]; % will be overridden
maxRadii  = [0, 0, 0]; % will be overridden
densities = [0, 0, 0]; % density per layer, will be overridden

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

% Make the boundary map.
boundNames = {'inner','outer','left','right'}; % keys, one per boundary
boundArrays = {[],[],[],[]}; % empty arrays to hold the photon object which crossed each boundary
iterativeLeftRightBoundsMap = containers.Map(boundNames, boundArrays);

%%% RAY TRACING
transmittedToInteriorLayer = sequentialRayTrace(initialPhotons, layersArray, iterativeLeftRightBoundsMap);
%singleRayTrace(initialPhotons, 1, layersArray);

%%% OUTPUTS
%disp("Number of photons that traversed each layer to reach and then escape the interior layer: " + size(transmittedToInteriorLayer,1))

%%% Helper functions
function photons = makeInitialPhotons(xStart, xEnd, separation, exteriorLayer, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to half the first layer's width. The initial photons are
  % separated by the value of the "separation" variable.
  nPhotons = (xEnd-xStart)/separation;
  disp("Num photons: " + nPhotons)
  photons = [];
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, exteriorLayer.latticeWidth/2, initialXStep, outerToInnerYStep);
    photons = [photons; nextPhoton];
  end
end

function incomingPhotons = prepareIncomingPhotons(nextLayer, transmittedPhotons)
  % Set the y-values of the incoming photons to match the height of the next layer.
  nIncomingPhotons = size(transmittedPhotons, 1);
  incomingPhotons = [];
  for i = 1:nIncomingPhotons
      oldPhoton = transmittedPhotons(i);
      nextPhoton = Photon(oldPhoton.x, nextLayer.getOuterBound(), oldPhoton.xStep, oldPhoton.yStep);
      incomingPhotons = [incomingPhotons; nextPhoton];
  end
end

function layerSummary(layerNum, photonsAtBoundsMap)
    % Summarize the information about a layer after it has been iterably ray traced.
    % During the iterative ray tracing loop, each loop produces a a Map of
    % each layer boundary -> a list of the photons which crossed that layer.
    % 
    % Currently uses this Map to print out the number of photons which crossed 
    % each boundary, but could conceivably print any information stored
    % in the photons in the Map.
    transmittedPhotons = photonsAtBoundsMap('inner');
    reflectedBack = photonsAtBoundsMap('outer');
    reflectedLeft = photonsAtBoundsMap('left');
    reflectedRight = photonsAtBoundsMap('right');
    disp("/===========================================================\")
    disp("Layer " + layerNum + " summary. List of photons reflected: ")
    disp("> through: " + size(transmittedPhotons,1) + " (transmitted)")
    disp(">    back: " + size(reflectedBack,1))
    disp(">    left: " + size(reflectedLeft,1))
    disp(">   right: " + size(reflectedRight,1))
    disp("\===========================================================/")
end

function transmittedToInterior = sequentialRayTrace(initialPhotons, layersArray, leftRightAtBoundsMap)
  % Iterate and ray trace each layer in a LayerStack.
  % The photons transmitted through one layer become
  % the incoming photons for the next layer.
  incomingPhotons = initialPhotons;
  rayTracer = RayTracer();
  for layerNum = 1:size(layersArray,2)
    %for p = 1:size(incomingPhotons)
    %  disp(incomingPhotons(p))
    %end
    layer = layersArray(layerNum);
    % Ray trace and receive a map of {boundary -> [photons]}.
    photonsAtBoundsMap = rayTracer.rayTrace(layer, incomingPhotons); 
    % Store the necessary photon arrays.
    transmittedPhotons = photonsAtBoundsMap('inner');
    leftRightAtBoundsMap('left')  = [leftRightAtBoundsMap('left');  photonsAtBoundsMap('left')];
    leftRightAtBoundsMap('right') = [leftRightAtBoundsMap('right'); photonsAtBoundsMap('right')];
    % Display results for this layer.
    layerSummary(layerNum, photonsAtBoundsMap);
    if layerNum < size(layersArray,2)
      incomingPhotons = prepareIncomingPhotons(layersArray(layerNum+1), transmittedPhotons);
    end
  end
  transmittedToInterior = transmittedPhotons;
end

function singleRayTrace(initialPhotons, layerNum, layersArray)
  % Ray trace a single layer. Shows a summary of the
  % photons that arrived at each boundary.
  layer = layersArray(layerNum);
  rayTracer = RayTracer(layer.getAxisHandle());
  incomingPhotons = initialPhotons;
  photonsAtBoundsMap = rayTracer.rayTrace(layer, incomingPhotons);
  layerSummary(layerNum, photonsAtBoundsMap);
end

function s = coordToString(coords)
  s = string(coords(1)) + ", " + string(coords(2));
end
