classdef LayerStacker
  % Gathers the relevant data from an array of layers,
  % indexed exterior to interior, and makes a single
  % Layer object representing these combined layers.
  properties (Constant)
    % We use these to generate the new layer, but will overwrite
    % the fiberData anyway, so these don't matter.
    dummyMinRadius    = 4*10^(-6);
    dummyMaxRadius    = 4.01*10^(-6);
    dummyDensity      = 0.0001; % no need to make a lot
  end

  properties
    layersArray
    combinedLength
    combinedWidth
    combinedFiberData
  end

  methods
    function obj = LayerStacker(layersArray)
      testLength = obj.validateLayers(layersArray);
      if testLength ~= -1
        obj.combinedLength = testLength;
        obj.combinedWidth = obj.sumWidths();
        obj.layersArray = layersArray;
      else
        error('Layers should all be the same length.')
      end
      % Make the combined fiberData.
      combinedFiberData = [];
      for layer = obj.layersArray
        combinedFiberData = [combinedFiberData; layer.getFiberData()];
      end
      obj.combinedFiberData = combinedFiberData;
    end

    function stack = makeLayerStack(obj)
      % Make a new layer and include the combinedFiberData
      % to overwrite the generated fibers.
      stack = Layer(obj.combinedLength / BubblebathFiberLattice.LATTICE_I, obj.combinedLength / BubblebathFiberLattice.LATTICE_J, LayerStacker.dummyMinRadius, LayerStacker.dummyMaxRadius, LayerStacker.dummyDensity, obj.combinedFiberData);
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
