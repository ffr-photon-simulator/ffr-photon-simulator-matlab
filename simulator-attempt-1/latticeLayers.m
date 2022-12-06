% Constants
i  = 7.0711 * 10^(-6); % i

% Make 4 Layer objects
outerLayer = Layer();
%Layer2 = Layer();
%Layer3 = Layer();
%Layer4 = Layer();

% Put Layers initialXCoord array to loop over
layersArray = [outerLayer]; %; Layer2; Layer3; Layer4];

negativeXCoord = -1*i; % initial coordinate of leftmost photon
initialXCoord = -1*i;  % initial coordinate of rightmost photon
initialYCoord = outerLayer.lattice.lattice_width;
initialCoordsStepMultiplier = 10; % multiplies x-distance between each initial incident photon
numPhotons = floor((2*abs(initialXCoord))/(outerLayer.lattice.general_photon_step*initialCoordsStepMultiplier));
disp("Num photons = " + numPhotons)

% Generate and store the initial coords
initialPhotonCoordsArray = [];
while (initialXCoord < abs(negativeXCoord))
    initialPhotonCoordsArray = [initialPhotonCoordsArray; initialXCoord, initialYCoord];
    initialXCoord = initialXCoord + (outerLayer.lattice.general_photon_step*initialCoordsStepMultiplier);
end

hold on;
plotPoints(initialPhotonCoordsArray,'k.'); % initial coords in black

% Run the ray tracing
finalPhotonCoordsArray = loopLayers(layersArray, initialPhotonCoordsArray);
for idx = 1:size(layersArray)
    layer = layersArray(idx);
    disp(">>> Boundary Summary for Layer " + idx)
    layer.lattice.boundarySummary(); % print boundary summary for each layer
end

%outerLayer.plotAll();
plotPoints(finalPhotonCoordsArray,'r.'); % final inner bound in red
absoluteFilePath = "/home/user/ffr-photon-simulator/Layers-images/"; % leave empty for current directory
%saved = saveFigure(layersArray, Layer1.lattice.number_fibers_in_length, Layer1.lattice.number_fibers_in_width);

% Save the plot as an image
function bool = saveFigure(layersArray, layer1Length, layer1Width, absoluteFilePath)
  frame = getframe(gcf);
  figureName = absoluteFilePath + size(layersArray) + "__" + layer1Length + "x" + layer1Width + "_layers.png";
  disp("### Figure saved as: " + figureName + "###")
  imwrite(frame.cdata, figureName)
  bool = true;
end

% Run the simulation by looping over the Layers recursively
function finalPhotonCoordsArray = loopLayers(layersArray, initialPhotonCoordsArray)
    % Base case. The final photon coords are the result of ray tracing
    % using the given initial coords.
    if size(layersArray) == 1
        finalPhotonCoordsArray = layersArray(1).rayTrace(initialPhotonCoordsArray);
        disp("=========Ray traced inner layer========")
    else
        % Make next initial photon coords array by recursing on the
        % previous layer to get its final photon coords array.
        % Don't run the final recursion (1:end-1)
        nextArray = makeNextInitialCoordsArray(layersArray(end), loopLayers(layersArray(1:end-1), initialPhotonCoordsArray));
        % Run the final recursion
        finalPhotonCoordsArray = layersArray(end).rayTrace(nextArray);
        disp("=========Ray traced layer=========")
    end
end

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

