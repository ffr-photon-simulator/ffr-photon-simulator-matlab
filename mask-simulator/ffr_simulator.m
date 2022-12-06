% Multipliers
separationMultiplier = 100; % multiplies separation between each initial photon
yStepMultiplier = 1; % multiplies y step

% Photon step information
initialXStep = 0;
outerToInnerYStep = -(Photon.WAVELENGTH/2)*yStepMultiplier;
innerToOuterYStep = -outerToInnerYStep;

separation = abs(outerToInnerYStep)*separationMultiplier;

% Iteratively create layers
nLayers = 2;
lengths = [10, 10]; % multiply by 10 microns
widths  = [10, 10]; % multiply by 10 microns
minRadii  = [0, 0];
maxRadii  = [0, 0];
densities = [0, 0]; % density per layer

% Cell array to store layers
layersCell = cell(1,nLayers);
for i = 1:nLayers
  layersCell{i} = Layer(lengths(i), widths(i), minRadii(i), maxRadii(i), densities(i));
end
%disp("Layers: ")
%disp(layersCell)

layersArray = [layersCell{:}];
disp(layersArray)
layerStack = LayerStack(layersArray); % convert cell array to array

initialPhotons = makeInitialPhotons(-3*BubblebathFiberLattice.LATTICE_I, 3*BubblebathFiberLattice.LATTICE_I, separation, layersArray(1), initialXStep, outerToInnerYStep);
%disp(initialPhotons)

% Boundary information storage
boundNames = {'inner','outer','left','right'};
boundArrays = {[],[],[],[]};
iterativeLeftRightBoundsMap = containers.Map(boundNames, boundArrays);

%%% Do the ray tracing
transmittedToInteriorLayer = iterativeRayTrace(initialPhotons, layersArray, iterativeLeftRightBoundsMap);

%%% Display Outputs
disp("Number of photons that traversed each layer to reach and then escape the interior layer: " + size(transmittedToInteriorLayer,1))
%disp(transmittedToInteriorLayer)

function photons = makeInitialPhotons(xStart, xEnd, separation, exteriorLayer, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to half the first layer's width.
  nPhotons = (xEnd-xStart)/separation;
  disp("Num photons: " + nPhotons)
  photons = [];
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, exteriorLayer.latticeWidth/2, initialXStep, outerToInnerYStep);
    %disp(nextPhoton)
    photons = [photons; nextPhoton];
  end
end

function transmittedPhotons = prepareIncomingPhotons(nextLayer, transmittedPhotons)
  nTransmittedPhotons = size(transmittedPhotons, 1);
  for i = 1:nTransmittedPhotons
    transmittedPhotons(i).setY(nextLayer.latticeWidth/2);
  end
  %incomingPhotons = nan(nTransmittedPhotons, 1); % pre-allocate
  %for i = 1:nTransmittedPhotons
    %photon = transmittedPhotons(i);
    %newPhoton = Photon(photon.x, nextLayer.latticeWidth/2, photon.xStep, photon.yStep);
    %incomingPhotons(i) = newPhoton;
  %end
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
  %disp(incomingPhotons)
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
