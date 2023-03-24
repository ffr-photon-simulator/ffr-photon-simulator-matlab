classdef FFRLayer < handle
  % Inherit from handle to set the nPhotons properties after the ray tracing finishes.
  properties
    quadrantLayers = [];
    lattice = []; % fiber data
    latticeWidth
    latticeLength
    outerBound
    innerBound
    % The photons going IN (aka "entering") are those which
    % cross the layer's upper bound from outer -> inner.
    % The photons going OUT (aka "exiting") are those which
    % cross the layer's inner bound from outer -> inner.
    % These values will be set only after the ray tracing finishes.
    nPhotonsIn
    nPhotonsOut
    id
  end

  methods
    function obj = FFRLayer(config)
      % Uses a config to create quadrant layers. The config 'c' is a struct of the form:
      % c.nQLayers = number of quadrant layers
      % c.layerType = type of layer ('inner, interior, filtering, or exterior')
      % c.qLayerConfigs = list of structs defining each quadrant layer

      % Give the layer a unique ID to avoid handle/value comparison issues.
      obj.id = extractBefore(char(java.util.UUID.randomUUID), 9); % 8 char hash

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
      outer = obj.outerBound.bound;
      inner = obj.innerBound.bound;
      bool = photon.y <= outer && photon.y > inner;
      %bool = false;
      %if photon.y <= obj.outerBound.bound
      %  if photon.y > obj.innerBound.bound
      %    bool = true;
      %  end
      %end
      Debug.msg("Contains photon: " + bool, 1);
      Debug.msg("outer: " + outer, 1);
      Debug.msg("inner: " + inner, 1);
      Debug.msg("photon at " + Debug.coordToString(photon.getCoords()), 1);
    end

    function showPhotonPercentage(obj, nPhotons)
      in = obj.nPhotonsIn;
      %inMinusOut = obj.nPhotonsIn - obj.nPhotonsOut;
      %pct = inMinusOut / nPhotons;
      %pct = in / nPhotons;
      Debug.msg(" - photons in: " + in, 0);
      %Defaults.debugMessage(" - as pct: " + pct, 1);
      %Defaults.debugMessage(" - photons out: " + obj.nPhotonsOut, 0);
      %Defaults.debugMessage(" - photons: " + inMinusOut, 0);
    end
  end
end
