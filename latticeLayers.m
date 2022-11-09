% Constants
i  = 7.0711 * 10^(-6); % i

% Make 4 Layer objects
Layer1 = Layer(8,4);
Layer2 = Layer(8,4);
Layer3 = Layer(8,4);
Layer4 = Layer(8,4);

% Put Layers in array to loop over
layersArray = [Layer1; Layer2; Layer3; Layer4];

initialPhotonCoordsArray = [];
initialXCoord = -i;
initialYCoord = Layer1.lattice.lattice_width;
numPhotons = (2*abs(initialXCoord))/(Layer1.lattice.general_photon_step*10);
disp("Num photons = " + numPhotons)
while (initialXCoord < i)
    initialPhotonCoordsArray = [initialPhotonCoordsArray; initialXCoord, initialYCoord];
    initialXCoord = initialXCoord + (Layer1.lattice.general_photon_step*10);
end

finalPhotonCoordsArray = loopLayers(layersArray, initialPhotonCoordsArray);
Layer4.plotAll();
plotPoints(finalPhotonCoordsArray,'r.');
plotPoints(initialPhotonCoordsArray,'k.')

% Loop over Layers recursively
function finalPhotonCoordsArray = loopLayers(layersArray, initialPhotonCoordsArray)
    if size(layersArray) == 1
        finalPhotonCoordsArray = layersArray(1).rayTrace(initialPhotonCoordsArray);
        disp("=========Ray traced first layer========")
    else
        nextArray = makeNextInitialCoordsArray(layersArray(end), loopLayers(layersArray(1:end-1), initialPhotonCoordsArray));
        finalPhotonCoordsArray = layersArray(end).rayTrace(nextArray);
        disp("=========Ray traced layer=========")
    end
end

% Display the photons that reached the inner bound
%disp(finalPhotonCoordsArray)

function array = makeNextInitialCoordsArray(layer, bottomBoundCoordArray)
    % Add the width of the lattice (positive y-value) to each y-value in
    % the previous bottom bound array to get initial coordinates that are
    % above the next array and won't start below it.
    array = [];
    for row = 1:size(bottomBoundCoordArray)
        array = [array; bottomBoundCoordArray(row,1), (bottomBoundCoordArray(row,2) + layer.lattice.lattice_width) ];
    end
end

function bool = plotPoints(array,color)
            plot(array(:,1), array(:,2),color,'MarkerSize',20);
            bool = true;
end

