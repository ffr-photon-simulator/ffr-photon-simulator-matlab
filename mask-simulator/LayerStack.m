classdef LayerStack < Layer
  % A data class for an array of layers. When the simulator
  % runs on the combined stack of layers, this class stores
  % information about that combined stack.
  %
  % The constructor takes the fiberData from each layer and
  % makes one giant layer from that data. The RayTracer
  % operates on a Layer, so LayerStack must inherit from Layer
  % to use the same ray tracer.
  properties
    layersArray
    latticeLength
    latticeWidth
    lattice
  end

  methods
    function obj = LayerStack(layersArray)
      testLength = obj.validateLayers(layersArray);
      if testLength ~= -1
        obj.latticeLength = testLength;
        obj.latticeWidth = obj.sumWidths();
        obj.layers = layers;
      else
        error('Layers should all be the same length.')
      end

      % Make a new BubblebathFiberLattice to get the figure
      % and the rest of the data, but set its fiberData to
      % the combinedLattice below.
      frameSize         = [obj.latticeLength, obj.latticeWidth];
      dummyMinRadius    = 4*10^(-6);
      dummyMaxRadius    = 4.01*10^(-6);
      dummyDensity      = 0.0001; % we will overwrite the fibers anyway, so no need to make a lot of them
      combinedFiberData = [];
      for layer = obj.layersArray
        combinedFiberData = [combinedFiberData; layer.getFiberData()];
      end
      obj.lattice = BubblebathFiberLattice(frameSize, dummyMinRadius, dummyMaxRadius, dummyDensity, combinedFiberData);

    end

    function length = validateLayers(obj, layersArray)
      length = layersArray(1).latticeLength;
      for i = 2:size(layersArray)
        if layersArray(i).getLength ~= length
          length = -1; % invalid layers
          return;
        end
      end
    end

    function width = sumWidths(obj)
      width = 0;
      for layer = obj.layersArray
        width = width + layer.latticeWidth;
      end
    end
  end
end
