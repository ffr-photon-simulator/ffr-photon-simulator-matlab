classdef FFR
  properties
    nLayers
    ffrLayers = [];
    boundaries = struct();
    ffrBounds = [];
    fiberData = [];
    model
  end

  methods
    function obj = FFR(config)
      obj.nLayers = config.nLayers;
      obj.model = config.model;

      ffrBounds = struct();
      ffrBounds.leftBound = FFRBoundary(config.boundaries.ffrBounds.leftBound, 'left');
      ffrBounds.rightBound = FFRBoundary(config.boundaries.ffrBounds.rightBound, 'right');
      ffrBounds.innerBound = FFRBoundary(config.boundaries.ffrBounds.innerBound, 'inner');
      ffrBounds.outerBound = FFRBoundary(config.boundaries.ffrBounds.outerBound, 'outer');
      obj.ffrBounds = ffrBounds;

      nInteriorBounds = size(config.boundaries.interiorBounds, 1);
      interiorBounds(1,nInteriorBounds) = InteriorBoundary(config.boundaries.interiorBounds(end));
      for i = 1:(nInteriorBounds - 1)
        interiorBounds(i) = InteriorBoundary(config.boundaries.interiorBounds(i));
      end
      interiorBounds = interiorBounds.';

      obj.boundaries.ffrBounds = ffrBounds;
      obj.boundaries.interiorBounds = interiorBounds;

      ffrLayerConfigs = config.ffrLayerConfigs;

      for i = 1:obj.nLayers
        ffrLayerConfig = ffrLayerConfigs(i);
        if i == 1
          ffrLayerConfig.innerBound = obj.boundaries.ffrBounds.innerBound;
        else
          ffrLayerConfig.innerBound = obj.boundaries.interiorBounds(i - 1);
        end
        if i == obj.nLayers
          ffrLayerConfig.outerBound = obj.boundaries.ffrBounds.outerBound;
        else
          ffrLayerConfig.outerBound = obj.boundaries.interiorBounds(i);
        end
        ffrLayer = FFRLayer(ffrLayerConfig);
        obj.ffrLayers = [obj.ffrLayers; ffrLayer];
      end

      obj.fiberData = obj.buildFiberData();
    end

    function fiberData = buildFiberData(obj)
      fiberData = [];
      for i = 1:size(obj.ffrLayers)
        ffrLayer = obj.ffrLayers(i);
        quadrantLayers = ffrLayer.quadrantLayers;
        for j = 1:size(quadrantLayers)
          quadrantLayer = quadrantLayers(j);
          quadrants = quadrantLayer.quadrants;
          for q = 1:size(quadrants)
            quadrant = quadrants(q);
            fiberData = [fiberData; quadrant.getFiberData()];
          end
        end
      end
    end

    function bounds = printBounds(obj)
      bounds = "FFR Bounds:\n-> Left: " + string(obj.ffrBounds.leftBound.bound);
    end

  end
end
