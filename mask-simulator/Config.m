classdef Config
  properties (Constant)
    % Keep user-defined values for each FFR here. The idea is
    % to avoid the user having to edit the config_*.m file.
    ffr_3M9210 = struct('qWidth', 100*Defaults.micron, ...
                        'qLength', 100*Defaults.micron, ...
                        'nLayers', 9, ...
                        'lengthI', 5000, ...
                        'layerRadiiI', [1 3; 1 3; 1 3; 1 3; 1 3; 1 3; 1 3; 1 3; 1 3], ...
                        'layerWidthsI', [100 100 100 100 100 100 100 100 100]);
  end
  methods (Static)
    function config = addFFRLayerBounds(ffrLayerConfig, ffrConfig, boundaries, i)
      if i == 1
        ffrLayerConfig.innerBound = 0;
      elseif i == ffrConfig.nLayers
        ffrLayerConfig.outerBound = boundaries.ffrBounds.outerBound;
      else
        ffrLayerConfig.outerBound = boundaries.interiorBounds(i);
        ffrLayerConfig.innerBound = boundaries.interiorBounds(i - 1);
      end
      config = ffrLayerConfig;
    end

    function config = buildFFRLayerConfig(width, nQLayers, radiiRange, densityRange, layerType, nQuadrantsPerQLayer)
      config = struct();
      config.width = width;
      if ~exist('nQLayers', 'var')
        config.nQLayers = 1;
      else
        config.nQLayers = nQLayers;
      end
      config.radiiRange = radiiRange;
      config.densityRange = densityRange;
      config.layerType = layerType;
      config.nQuadrantsPerQLayer = nQuadrantsPerQLayer;
    end

    function config = buildQuadrantLayerConfig(ffrConfig, outerHeight, qLength, qWidth, nQuadrants)
      config = struct();
      config.nQuadrants = nQuadrants;
      config.width = qWidth;
      config.length = ffrConfig.length;
      config.heightOffset = outerHeight + (config.width * 0.5);
    end

    function config = buildQuadrantConfig(ffrConfig, length, width, ...
                                          layerRadiiRange, layerDensityRange, ...
                                          heightOffset, lengthOffset)
      config = struct();
      config.length = length;
      config.width = width;
      config.frameSize = [config.length config.width];
      config.minRadius = layerRadiiRange(1) * Defaults.micron; % integer range
      config.maxRadius = layerRadiiRange(2) * Defaults.micron; % integer range
      config.circSize = [config.minRadius config.maxRadius];
      config.density = randi([layerDensityRange(1) layerDensityRange(2)]) / 10000000000;
      config.heightOffset = heightOffset;
      config.lengthOffset = lengthOffset + (config.length / 2);
    end

    function struct = inputOrDefault(prompt, struct, fieldName, default)
      % Read user input and append it (or default) to a given list.
      var = input("> " + prompt + " (" + default + ") ");
      if isempty(var)
        var = default;
      end
      struct.(fieldName) = var;
    end

    function microns = toMicrons(int)
      % "Convert" an integer to microns by multiplication.
      microns = int * Defaults.micron;
    end
  end
end
