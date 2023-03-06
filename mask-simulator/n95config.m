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
  % Density: multiply to microns and then divide by 100 to make densities a useful value.
  config.density = (randi([layerDensityRange(1) layerDensityRange(2)]) / 100) * Defaults.micron;
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
