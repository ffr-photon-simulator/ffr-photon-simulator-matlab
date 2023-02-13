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
