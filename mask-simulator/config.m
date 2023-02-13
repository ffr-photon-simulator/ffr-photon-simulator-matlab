%%% Configuration file for the simulator.
% The FFR is configured from FFR -> FFR layers -> quadrant layers -> quadrants.
% You must edit this config file to configure the FFR, and functions will
% prompt you for the remaining configuration parameters. There will always be
% a default option.

% FFR Config (struct)
%   ffrConfig.nLayers
%   ffrConfig.ffrLayerConfigs (list of structs 'ls')
%     ls.nQLayers
%     ls.layerType
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
%         qs.lengthOffset
%         qs.width = qls.width
%         qs.frameSize = [length, width]
%         qs.circSize = [minRadius, maxRadius]
%

% The FFR config
ffrConfig = struct();
ffrConfig = structInputOrDefault("How many FFR layers?", ffrConfig, 'nLayers', Defaults.nLayers);

% Iterate over nLayers to build the ffrLayerConfigs
ffrLayerConfigs = []; % add the struct configs to this list
disp("All layers are numbered from 1 (inner) to n (outer).")
% Start the heightOffset at 0
heightOffset = 0;
for l = 1:ffrConfig.nLayers
  disp("")
  disp("# Configure FFR layer " + l + ".")
  ls = struct();
  ls = structInputOrDefault("How many quadrant layers?", ls, 'nQLayers', Defaults.nQLayers);
  ls = structInputOrDefault("Layer type?", ls, 'layerType', Defaults.layerType);
  qLayerConfigs = [];

  % Iterate over each quadrant layer and build its config
  for ql = 1:ls.nQLayers
    disp("")
    disp("## Configure quadrant layer " + ql + ".")
    qls = struct();
    qls = structInputOrDefault("How many quadrants?", qls, 'nQuadrants', Defaults.nQuadrants);
    qls = structInputOrDefault("Width?", qls, 'width', Defaults.qlWidth);
    % bubblebath_noPlot() is centered at [0,0], so add half ql width to actual offset.
    qls.heightOffset = heightOffset + (qls.width * 0.5);
    % Increment heightOffset by the full width of this layer for the next layer.
    heightOffset = heightOffset + qls.width;
    qls.length = 0; % starting value, add to it after making the quadrants
    quadrantConfigsv1 = [];
    quadrantConfigs = [];

    % Iterate over each quadrant and build its config
    for q = 1:qls.nQuadrants
      disp("")
      disp("### Configure quadrant " + q + ".")
      qsv1 = struct();
      qsv1 = structInputOrDefault("Length?", qsv1, 'length', Defaults.qLength);
      qsv1 = structInputOrDefault("Min fiber radius?", qsv1, 'minRadius', Defaults.minRadius);
      qsv1 = structInputOrDefault("Max fiber radius?", qsv1, 'maxRadius', Defaults.maxRadius);
      qsv1 = structInputOrDefault("Density?", qsv1, 'density', Defaults.density);
      qsv1.width = qls.width;
      qsv1.frameSize = [qsv1.length, qsv1.width];
      qsv1.circSize = [qsv1.minRadius, qsv1.maxRadius];

      % Add quadrant length to the quadrant layer length.
      qls.length = qls.length + qsv1.length;
      % Add the quadrant struct to the list
      quadrantConfigsv1 = [quadrantConfigsv1; qsv1];
    end
    % Start the lengthOffset at half of the length (negative),
    % which centers the quadrant layer on the x-axis.
    lengthOffset = -qls.length / 2;
    % Iterate through the quadrants again to set their lengthOffset,
    % which is just the previous lengthOffset plus half its own length.
    for q = 1:size(quadrantConfigsv1)
      qs = quadrantConfigsv1(q);
      qs.lengthOffset = lengthOffset + (qs.length / 2);
      quadrantConfigs = [quadrantConfigs; qs];
      % Increment the lengthOffset to set the new starting coordinate.
      lengthOffset = lengthOffset + qs.length;
      disp(">>> Quadrant config")
      disp(qs)
    end

    % Add the list of quadrant configs to the quadrant layer struct
    qls.quadrantConfigs = quadrantConfigs;

    % Add the quadrant layer config to the list of quadrant layer structs
    qLayerConfigs = [qLayerConfigs; qls];
    disp(">> Quadrant layer config:")
    disp(qls)
  end

  % Add the quadrant layer config list to the ffr layer struct
  ls.qLayerConfigs = qLayerConfigs;
  disp("> FFR Layer config")
  disp(ls)

  % Add the ffr layer struct to the list
  ffrLayerConfigs = [ffrLayerConfigs; ls];
end

% Add the ffrLayerConfigs list to the ffrConfig struct
ffrConfig.ffrLayerConfigs = ffrLayerConfigs;

disp("FFR Config")
disp(ffrConfig)

