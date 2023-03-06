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


function struct = inputOrDefault(prompt, struct, fieldName, default)
  % Read user input and append it (or default) to a given list.
  var = input("> " + prompt + " (" + default + ") ");
  if isempty(var)
    var = default;
  end
  struct.(fieldName) = var;
end
