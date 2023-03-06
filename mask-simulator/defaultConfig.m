%%% Configuration file for the simulator.
% The FFR is configured from FFR -> FFR layers -> quadrant layers -> quadrants.
% You must edit this config file to configure the FFR, and functions will
% prompt you for the remaining configuration parameters. There will always be
% a default option.

% FFR Config (struct)
%   ffrConfig.nLayers
%   ffrConfig.width
%   ffrConfig.boundaries (struct 'bs' with boundary data)
%     bs.leftBound = -x
%     bs.rightBound = +x
%     bs.innerBound = 0
%     bs.outerBound = height offset
%     bs.interiorBounds = [y1, y2, ...]
%   ffrConfig.ffrLayerConfigs (list of structs 'ls')
%     ls.nQLayers
%     ls.layerType
%     ls.width
%     ls.qLayerConfigs (list of structs 'qls')
%       qls.nQuadrants
%       qls.width
%       qls.length
%       qls.heightOffset
%       qls.quadrantConfigs (list of structs 'qs')
%         qs.minRadius
%         qs.maxRadius
%         qs.density
%         qs.length
%         qs.heightOffset
%         qs.lengthOffset
%         qs.width = qls.width
%         qs.frameSize = [length, width]
%         qs.circSize = [minRadius, maxRadius]
%
% The ffrLayerConfigs list represents outer to inner layers.
% The qLayerConfigs list represents outer to inner layers.
% The quadrantConfigs list represents left to right quadrants.

% The FFR config
ffrConfig = struct();
ffrConfig.nLayers = 4;
ffrConfig.length = 50 * Defaults.LATTICE_I; % 5 * 10^(-4);
%ffrConfig = structInputOrDefault("How many FFR layers?", ffrConfig, 'nLayers', Defaults.nLayers);

%function struct = structInputOrDefault(prompt, struct, fieldName, default)
%  % Read user input and append it (or default) to a given list.
%  var = input("> " + prompt + " (" + default + ") ");
%  if isempty(var)
%    var = default;
%  end
%  struct.(fieldName) = var;
%end

% Iterate over nLayers to build the ffrLayerConfigs
ffrLayerConfigs = []; % add the struct configs to this list
%disp("All layers are numbered from 1 (inner) to n (outer).")
% Start the heightOffset at 0. The height offset is the outer bound height of the previous layer.
% The height offset is added to each quadrant layer's config while the quadrant layers are being generated.
% Once each FFR layer is generated, the height offset is the width of that FFR Layer, and the height offset
% becomes the y coordinate of the Boundary following that FFR layer.
heightOffset = 0;
% Iterate over number of FFR Layers and build their configs
for l = 1:ffrConfig.nLayers
  ffrLayerStruct = struct();
  ffrLayerStruct.nQLayers = randi([1 3]);
  ffrLayerStruct.layerType = Defaults.layerType;
  quadrantLayerConfigs = [];

  % Iterate over each quadrant layer and build its config
  for ql = 1:ffrLayerStruct.nQLayers
    quadrantLayerStruct = struct();
    quadrantLayerStruct.nQuadrants = randi([2 6]);
    quadrantLayerStruct.width = randi([1 3]) * Defaults.LATTICE_J;
    % bubblebath_noPlot() is centered at [0,0], so add half ql width to the quadrant layer's height offset.
    quadrantLayerStruct.heightOffset = heightOffset + (quadrantLayerStruct.width * 0.5);
    % Increment heightOffset by the full width of this layer for the next layer.
    heightOffset = heightOffset + quadrantLayerStruct.width;
    quadrantLayerStruct.length = 0; % starting value, add to it after making the quadrants
    quadrantConfigsNoLengthOffset = [];
    quadrantConfigs = [];

    % Iterate over each quadrant and build its config.
    % We can't know the length offset of the quadrants until we know how many
    % there are and each of their lengths, since we build the quadrants left
    % to right but center them around x = 0 when generating their lattice data.
    % Thus, we have to go back and add a length offset to each quadrant's struct
    % after this initial loop. The Quadrants will handle actually adding the
    % length offset values to their data once they're instantiated.
    quadrantLengths =
    for q = 1:quadrantLayerStruct.nQuadrants
      quadrantStructNoLengthOffset = struct(); % quadrant struct version 1
      quadrantStructNoLengthOffset.length    = randi([1 3]) * Defaults.LATTICE_I;
      quadrantStructNoLengthOffset.minRadius = Defaults.minRadius;
      quadrantStructNoLengthOffset.maxRadius = Defaults.maxRadius;
      quadrantStructNoLengthOffset.density = Defaults.density;
      quadrantStructNoLengthOffset.heightOffset = quadrantLayerStruct.heightOffset;
      quadrantStructNoLengthOffset.width = quadrantLayerStruct.width;
      quadrantStructNoLengthOffset.frameSize = [quadrantStructNoLengthOffset.length, quadrantStructNoLengthOffset.width];
      quadrantStructNoLengthOffset.circSize = [quadrantStructNoLengthOffset.minRadius, quadrantStructNoLengthOffset.maxRadius];

      % Add quadrant length to the quadrant layer length.
      quadrantLayerStruct.length = quadrantLayerStruct.length + quadrantStructNoLengthOffset.length;
      % Add the quadrant struct to the list
      quadrantConfigsNoLengthOffset = [quadrantConfigsNoLengthOffset; quadrantStructNoLengthOffset];
    end

    % Start the lengthOffset at half of the length (negative),
    % which centers the quadrant layer on the x-axis.
    lengthOffset = -quadrantLayerStruct.length / 2;

    % Iterate through the quadrants again to set their lengthOffset,
    % which is just the previous lengthOffset plus half its own length.
    for q = 1:size(quadrantConfigsNoLengthOffset)
      quadrantStruct = quadrantConfigsNoLengthOffset(q);
      quadrantStruct.lengthOffset = lengthOffset + (quadrantStruct.length / 2);
      quadrantConfigs = [quadrantConfigs; quadrantStruct];
      % Increment the lengthOffset to set the new starting coordinate.
      lengthOffset = lengthOffset + quadrantStruct.length;
      %disp(">>> Quadrant config")
      %disp(quadrantStruct)
    end

    % Add the list of quadrant configs to the quadrant layer struct
    quadrantLayerStruct.quadrantConfigs = quadrantConfigs;

    % Add the quadrant layer config to the list of quadrant layer structs
    quadrantLayerConfigs = [quadrantLayerConfigs; quadrantLayerStruct];
    %disp(">> Quadrant layer config:")
    %disp(quadrantLayerStruct)
  end

  % Add the quadrant layer config list to the ffr layer struct
  ffrLayerStruct.quadrantLayerConfigs = quadrantLayerConfigs;
  %disp("> FFR Layer config")
  %disp(ffrLayerStruct)

  % The height offset is now equal to the width of the completed FFR Layer.
  ffrLayerStruct.width = heightOffset;

  % Add the ffr layer struct to the list
  ffrLayerConfigs = [ffrLayerConfigs; ffrLayerStruct];
end

% Add the ffrLayerConfigs list to the ffrConfig struct
ffrConfig.ffrLayerConfigs = ffrLayerConfigs;

% The height offset is now equal to the ffr's width.
ffrConfig.width = heightOffset;

% Make the Boundary configs.
% We always need four FFR boundaries: left, right, outer, inner
boundaries = struct();
boundaries.ffrBounds = struct();
boundaries.ffrBounds.leftBound  = -ffrConfig.length / 2;
boundaries.ffrBounds.rightBound =  ffrConfig.length / 2;
boundaries.ffrBounds.innerBound = 0;
boundaries.ffrBounds.outerBound = ffrConfig.width;
boundaries.interiorBounds = [];

% Make a list of interior bound y-values
for l = ffrLayerConfigs
  boundaries.interiorBounds = [boundaries.interiorBounds; l.width];
end

ffrConfig.boundaries = boundaries;

%disp("FFR Config")
%disp(ffrConfig)

function struct = structInputOrDefault(prompt, struct, fieldName, default)
  % Read user input and append it (or default) to a given list.
  var = input("> " + prompt + " (" + default + ") ");
  if isempty(var)
    var = default;
  end
  struct.(fieldName) = var;
end

function appendInputOrDefault(prompt, list, default)
  % Read user input and append it (or default) to a given list.
  var = input("> " + prompt + " (" + default + ") ");
  if isempty(var)
    var = default;
  end
  list = [list; var];
end

function length = findGreatestQuadrantLayerLength(quadrantLayerConfigs)
  length = 0;
  for i = 1:size(quadrantLayerConfigs)
    quadrantLayer = quadrantLayerConfigs(i);
    if quadrantLayer.length > length
      length = quadrantLayer.length;
    end
  end
end
