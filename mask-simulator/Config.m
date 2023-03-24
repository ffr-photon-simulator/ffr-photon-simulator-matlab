classdef Config
  properties (Constant)
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

    function config = buildFFRLayerConfig()
      config = struct();
      %config.nQLayers = randi([1 3]);
      config.nQLayers = 1;
      config.layerType = Defaults.layerType;
    end

    function config = buildQuadrantLayerConfig(ffrConfig, outerHeight, qLength, qWidth)
      config = struct();
      config.nQuadrants = ffrConfig.length / qLength;
      config.width = qWidth;
      config.length = ffrConfig.length;
      config.heightOffset = outerHeight + (config.width * 0.5);
    end

    function config = buildQuadrantConfig(ffrConfig, length, width, ...
                                          layerRadiiRange, layerDensityRange, ...
                                          heightOffset, lengthOffset)
      config = struct();
      config.length = Defaults.qLengthN95;
      config.width = Defaults.qWidthN95;
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
