% Configuration file to simulate ray tracing with a 3M 1860 FFR.

% Default variables. This will move elsewhere later.
qWidth = 80 * Defaults.micron; % quadrant width
qLength = qWidth; % quadrant length

% The FFR config, later renamed to ffrConfig.
c = struct();
c.nLayers = 3; % number of FFR layers
% Length
c.lengthI = 800;
c.length = Config.toMicrons(c.lengthI);
% Radii ranges.
% Each row represents an FFR layer. The left and right
% columns represent the bounds of the range.
c.layerRadiiI = [3 7; 1 5; 3 7];
c.layerRadii  = Config.toMicrons(c.layerRadiiI);
% Density ranges.
% The density is a value between 0 and 1. It is altered later
% (probably scaled down) to make it more appropriate for the
% given quadrant size.
c.layerDensitiesI = [1 2; 1 2; 1 2];

% FFR layer widths.
c.layerWidthsI = [80 160 80]; % list, not 3-row matrix
c.layerWidths = Config.toMicrons(c.layerWidthsI);
% FFR width.
widthI = 0;
for w = c.layerWidthsI
  widthI = widthI + w;
end
c.widthI = widthI;
c.width = Config.toMicrons(c.widthI);

%%%%%%%%%%%%%%%%%%%%%%%%%
%   FFR Layer Configs   %
%%%%%%%%%%%%%%%%%%%%%%%%%
ffrLayerConfigs = [];
% The y-value (height) of the current outer layer.
% This will increase and eventually total the FFR width.
outerBoundHeight = 0;
for i = 1:c.nLayers
  l = Config.buildFFRLayerConfig();
  l.width = c.layerWidths(i);
  l.nQLayers = l.width / qWidth; % qLayers are same width as quadrants
  radiiRange = c.layerRadiiI(i, :); % want integers
  densityRange = c.layerDensitiesI(i, :); % want integers
  if i == 1
    l.layerType = 'inner';
  elseif i == c.nLayers
    l.layerType = 'outer';
  else
    l.layerType = 'filtering';
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   Quadrant Layer Configs   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  quadrantLayerConfigs = [];
  for j = 1:l.nQLayers
    ql = Config.buildQuadrantLayerConfig(c, outerBoundHeight);
    % Add the quadrant layer's width to the outer bound height.
    outerBoundHeight = outerBoundHeight + ql.width;

    %%%%%%%%%%%%%%%%%%%%%%%%
    %   Quadrant Configs   %
    %%%%%%%%%%%%%%%%%%%%%%%%
    quadrantConfigs = [];
    % The length offset is necessary, in addition to the outerBoundHeight,
    % to transform the fiber lattice after it's been generated about (0,0).
    lengthOffset = -ql.length / 2;
    for k = 1:ql.nQuadrants
      q = Config.buildQuadrantConfig(c, radiiRange, densityRange, ql.heightOffset, lengthOffset);
      % Add the quadrant's length to the length offset.
      lengthOffset = lengthOffset + q.length;

      % Assemble the quadrant configs.
      quadrantConfigs = [quadrantConfigs; q];
    end

    % Put the quadrant configs in the quadrant layer config.
    ql.quadrantConfigs = quadrantConfigs;

    % Assemble the quadrant layer configs.
    quadrantLayerConfigs = [quadrantLayerConfigs; ql];
  end

  % Put the quadrant layer configs in the FFR layer config.
  l.quadrantLayerConfigs = quadrantLayerConfigs;

  % Assemble the FFR layer configs.
  ffrLayerConfigs = [ffrLayerConfigs; l];
end

% Put the FFR layer configs in the FFR config.
c.ffrLayerConfigs = ffrLayerConfigs;

%%%%%%%%%%%%%%%%%%%%%%%%
%   Boundary Configs   %
%%%%%%%%%%%%%%%%%%%%%%%%
boundaries = struct();
% FFR Bounds (x or y values).
ffrBounds = struct();
ffrBounds.leftBound  = -c.length / 2;
ffrBounds.rightBound =  c.length / 2;
ffrBounds.innerBound = 0;
ffrBounds.outerBound = c.width;

% Interior Bounds (y values).
% Use a list to store the values because the interior bound order is significant.
% As with the FFR Layer configs, the interior bound list goes from inner -> outer.
interiorBounds = [];
bound = 0;

% There are n - 1 interior bounds for n FFR layers
for i = 1:(c.nLayers - 1)
  bound = bound + ffrLayerConfigs(i).width;
  interiorBounds = [interiorBounds; bound];
end

% Assemble boundary configs.
boundaries.ffrBounds = ffrBounds;
boundaries.interiorBounds = interiorBounds;
c.boundaries = boundaries;


%%%%%%%%%%%%%%%%%%
%   FFR Config   %
%%%%%%%%%%%%%%%%%%
ffrConfig = c;
