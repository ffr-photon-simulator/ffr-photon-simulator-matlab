classdef FFRLayer < handle
  properties
    quadrantLayers = [];
    nQLayers
    lattice = []; % fiber data
    latticeWidth
    latticeLength
    outerBound
    innerBound
    nPhotonsIn
    nPhotonsOut
    id
    nFibers
    possibleAbsorptionCount = 0;
  end

  methods
    function obj = FFRLayer(config)
      if nargin > 0
        obj.id = extractBefore(char(java.util.UUID.randomUUID), 9); % 8 char hash

        obj.outerBound = config.outerBound;
        obj.innerBound = config.innerBound;

        qLayerConfigs = config.quadrantLayerConfigs; % [struct1, struct2, struct3, ...]
        obj.nQLayers = config.nQLayers;

        q = 1:obj.nQLayers;
        obj.quadrantLayers = QuadrantLayer(qLayerConfigs(q));

        obj.nFibers = sum([obj.quadrantLayers.nFibers]);

        obj.lattice = obj.makeLattice(config.nQLayers, config.nQuadrantsPerQLayer);
      end
    end

    function lattice = makeLattice(obj, nQLayers, nQuadrantsPerQLayer)
      lattice = [];
      %nFibers = single(nQLayers * nQuadrantsPerQLayer * 20); % assume 30 fibers per quadrant
      % Pre-allocate the lattice
      %lattice = nan(nFibers, 3);
      n = 1:nQLayers;
      lattice = obj.quadrantLayers(n).getFiberData();
    end

    function bool = containsPhoton(obj, photon)
      outer = obj.outerBound.bound;
      inner = obj.innerBound.bound;
      bool = photon.y <= outer && photon.y > inner;
    end

    function showPhotonPercentage(obj, nPhotons)
      in = obj.nPhotonsIn;
      %inMinusOut = obj.nPhotonsIn - obj.nPhotonsOut;
      %pct = inMinusOut / nPhotons;
      %pct = in / nPhotons;
      Debug.msg(" - photons in: " + in, 0);
      Debug.msg(" - possible photon absorption count: " + string(obj.possibleAbsorptionCount), 0);
      %Defaults.debugMessage(" - as pct: " + pct, 1);
      %Defaults.debugMessage(" - photons out: " + obj.nPhotonsOut, 0);
      %Defaults.debugMessage(" - photons: " + inMinusOut, 0);
    end

    function incrementAbsorptionCount(obj)
      obj.possibleAbsorptionCount = obj.possibleAbsorptionCount + 1;
    end

  end
end
