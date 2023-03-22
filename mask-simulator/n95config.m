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

% This N95 config is designed to replicate the __ N95 FFR as studied in the following paper:
% https://groups.oist.jp/nnp/diy-face-mask.
% A length is specified for the FFR (multiple of 20 microns).
% A width (multiple of 20 microns), radius range, and density range is specified for each FFR Layer.
% Each quadrant layer is one quadrant wide, and each quadrant is 20 microns wide. The number
% of quadrant layers generated is the ql.width / 20. Each quadrant is 20 microns long, so the
% number of quadrants per layer is ffr.length / 20. Each quadrant has a randomized radii range and
% density.

% Notes on scale:
% It's simpler to note certain values as integers and put multipliers in the Defaults class.
% For example, in addition to specifying the FFR length in microns, we specify "400" in the "lengthI"
% variable, and then multiply that value by Defaults.micron later, if necessary. Any variable
% with the "I" suffix is an integer variable, and the variable of the same name without the suffix
% is the integer variable multiplied by Defaults.micron.
%
% The following variables have integer pairs:
% 1. ffrConfig.length
% 2. ffrConfig.width
% 2. ffrConfig.layerWidths
% 2. ffrConfig.layerRadii
% 2. ffrConfig.layerDensities

% The FFR config
ffrConfig = struct();
ffrConfig.nLayers = 3;
% Length
ffrConfig.lengthI = 800;
ffrConfig.length = ffrConfig.lengthI * Defaults.micron; % 5 * 10^(-4);
% Radii ranges: between 7 and 10 for layer 1, and so on
ffrConfig.layerRadiiI = [7 10; 1 8; 7 10];
ffrConfig.layerRadii = ffrConfig.layerRadiiI * Defaults.micron;
% Density: value between 0 and 1. Anything greater than 0.1 ends up being fairly high density,
% so divide this value by 100 to make the densities a useful value (<= 0.1).
ffrConfig.layerDensitiesI = [1 3; 3 8; 1 3];

% Calculate FFR width
ffrConfig.layerWidthsI = [80 160 80];
ffrConfig.layerWidths = ffrConfig.layerWidthsI * Defaults.micron;
% Total width
widthI = 0;
for w = ffrConfig.layerWidthsI
  widthI = widthI + w;
end
ffrConfig.widthI = widthI;
ffrConfig.width = ffrConfig.widthI * Defaults.micron;

% DONE: Make separate struct builder functions for each component of the FFR (FFR Layers, Q Layers, etc).
% DONE: Set the FFR length at the beginning.
% DONE: Randomly generate nQuadrant lengths (one for each quadrant). Use a for loop until the penultimate,
%       quadrant length, which  just the ffr length minus the length so far.

% Make FFR Layer config structs
ffrLayerConfigs = [];
outerHeight = 0; % height of current outer layer (will increase to reach FFR width)
for i = 1:ffrConfig.nLayers
  l = buildFFRLayerConfig();
  l.width = ffrConfig.layerWidths(i);
  l.nQLayers = l.width / Defaults.qWidthN95; %
  l.layerType = Defaults.layerType;
  layerRadiiRange = ffrConfig.layerRadiiI(i, :); % we want integers here
  layerDensityRange = ffrConfig.layerDensitiesI(i, :); % we want integers here

  % Make Quadrant Layer config structs
  quadrantLayerConfigs = [];
  for j = 1:l.nQLayers
    ql = buildQuadrantLayerConfig(ffrConfig, outerHeight);
    outerHeight = outerHeight + ql.width;

    % Make Quadrant config structs
    quadrantConfigs = [];
    lengthOffset = -ql.length / 2;
    for k = 1:ql.nQuadrants
      q = buildQuadrantConfig(ffrConfig, layerRadiiRange, layerDensityRange, ql.heightOffset, lengthOffset);
      lengthOffset = lengthOffset + q.length;
      quadrantConfigs = [quadrantConfigs; q];
      %disp(" >> Quadrant config: ")
      %disp(q)
    end

    ql.quadrantConfigs = quadrantConfigs;
    quadrantLayerConfigs = [quadrantLayerConfigs; ql];
    %disp(" >> Quadrant layer config: ")
    %disp(ql)
  end

  l.quadrantLayerConfigs = quadrantLayerConfigs;
  ffrLayerConfigs = [ffrLayerConfigs; l];
  %disp(" > FFR Layer config:")
  %disp(l)
end

ffrConfig.ffrLayerConfigs = ffrLayerConfigsBounds;

% Make the boundary configs.
boundaries = struct();
ffrBounds = struct();
ffrBounds.leftBound  = -ffrConfig.length / 2;
ffrBounds.rightBound =  ffrConfig.length / 2;
ffrBounds.innerBound = 0;
ffrBounds.outerBound = ffrConfig.width;
Defaults.debugMessage("FFR Bounds:\n", 1);
Defaults.debugStruct(ffrBounds, 1);
boundaries.ffrBounds = ffrBounds; % nested struct for ffr bounds

% Make a list of interior bound y-values. Use a list because the interior bound order is significant.
interiorBounds = [];
bound = 0;
% There are n-1 interior bound for n FFR layers
for i = 1:(size(ffrLayerConfigs) - 1)
  bound = bound + ffrLayerConfigs(i).width;
  interiorBounds = [interiorBounds; bound];
end
Defaults.debugMessage("Interior Bounds:\n", 1);

boundaries.interiorBounds = interiorBounds;
ffrConfig.boundaries = boundaries;

%%% FUNCTIONS

function config = buildFFRLayerConfig()
  config = struct();
  config.nQLayers = randi([1 3]);
  config.layerType = Defaults.layerType;
end


function config = buildQuadrantLayerConfig(ffrConfig, outerHeight)
  config = struct();
  config.nQuadrants = ffrConfig.length / Defaults.qLengthN95;
  config.width = Defaults.qWidthN95; % width of quadrant
  config.length = ffrConfig.length;
  config.heightOffset = outerHeight + (config.width * 0.5);
end

function config = buildQuadrantConfig(ffrConfig, layerRadiiRange, layerDensityRange, heightOffset, lengthOffset)
  config = struct();
  config.length = Defaults.qLengthN95;
  config.minRadius = layerRadiiRange(1) * Defaults.micron; % integer range
  config.maxRadius = layerRadiiRange(2) * Defaults.micron; % integer range
  config.density = randi([layerDensityRange(1) layerDensityRange(2)]) / 100;
  config.heightOffset = heightOffset;
  config.lengthOffset = lengthOffset + (config.length / 2);
  config.width = Defaults.qWidthN95;
  config.frameSize = [config.length config.width];
  config.circSize = [config.minRadius config.maxRadius];
end

function struct = inputOrDefault(prompt, struct, fieldName, default)
  % Read user input and append it (or default) to a given list.
  var = input("> " + prompt + " (" + default + ") ");
  if isempty(var)
    var = default;
  end
  struct.(fieldName) = var;
end
