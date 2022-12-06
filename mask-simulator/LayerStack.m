classdef LayerStack
  % A data class for an array of layers. When the simulator
  % runs on the combined stack of layers, this class stores
  % information about that combined stack.
  properties
    layers
    width
    length
  end

  methods
    function obj = LayerStack(layers)
      testLength = obj.validateLayers(layers);
      if testLength ~= -1
        obj.layers = layers;
        obj.length = testLength;
        obj.width = obj.sumWidths();
      else
        error('Layers should all be the same length.')
      end
    end

    function length = validateLayers(obj, layers)
      length = layers(1).latticeLength;
      for i = 2:size(layers)
        if layers(i).getLength ~= length
          length = -1; % invalid layers
          return;
        end
      end
    end

    function width = sumWidths(obj)
      width = 0;
      for layer = obj.layers
        width = width + layer.latticeWidth;
      end
    end
  end
end
