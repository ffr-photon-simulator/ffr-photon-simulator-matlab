classdef FFRLayer
  properties
    quadrantLayers = [];
    lattice = []; % fiber data
    latticeWidth
    latticeLength
    outerBound
    innerBound
  end

  methods
    function obj = FFRLayer(config)
      % Uses a config to create quadrant layers. The config 'c' is a struct of the form:
      % c.nQLayers = number of quadrant layers
      % c.layerType = type of layer ('inner, interior, filtering, or exterior')
      % c.qLayerConfigs = list of structs defining each quadrant layer

      % Set the bounds of this layer.
      obj.outerBound = config.outerBound;
      obj.innerBound = config.innerBound;

      % Store list of structs which are the configs of the quadrant layers.
      % Each quadrant layer struct holds the data to make that quadrant layer.
      qLayerConfigs = config.quadrantLayerConfigs; % [struct1, struct2, struct3, ...]

      % Create QuadrantLayers
      for q = 1:config.nQLayers
        quadrantLayer = QuadrantLayer(qLayerConfigs(q));
        obj.quadrantLayers = [obj.quadrantLayers; quadrantLayer];
      end

      % Aggregate fiber data from the quadrant layers
      obj.lattice = obj.makeLattice(config.nQLayers);
    end

    function lattice = makeLattice(obj, nLayers)
      % Add the fiber data from each quadrant layer to this ffr layer.
      lattice = [];
      for n = 1:nLayers
        lattice = [lattice; obj.quadrantLayers(n).getFiberData()];
      end
    end

    function bool = containsPhoton(obj, photon)
      % Check if a photon is inside this layer.
      bool = false;
      if photon.y <= obj.outerBound.bound
        if photon.y >= obj.innerBound.bound
          bool = true;
        end
      end
    end
  end
end
