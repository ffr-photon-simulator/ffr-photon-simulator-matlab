classdef FFR
  % A class representing an FFR.
  properties
    nLayers
    ffrLayers = [];
    boundaries = struct();
    ffrBounds = [];
    fiberData = [];
  end

  methods
    function obj = FFR(config)
      % The config 'c' is a struct of the form:
      % c.nLayers = number of layers in FFR
      % c.ffrLayerConfigs = list of structs defining each FFRLayer

      obj.nLayers = config.nLayers;

      % Create Boundaries
      % FFR bounds
      ffrBounds = struct();
      ffrBounds.leftBound = FFRBoundary(config.boundaries.ffrBounds.leftBound, 'left');
      ffrBounds.rightBound = FFRBoundary(config.boundaries.ffrBounds.rightBound, 'right');
      ffrBounds.innerBound = FFRBoundary(config.boundaries.ffrBounds.innerBound, 'inner');
      ffrBounds.outerBound = FFRBoundary(config.boundaries.ffrBounds.outerBound, 'outer');
      obj.ffrBounds = ffrBounds;

      % Interior bounds
      nInteriorBounds = size(config.boundaries.interiorBounds, 1);
      % Preallocate the array and create the last InteriorBoundary in the array.
      interiorBounds(1,nInteriorBounds) = InteriorBoundary(config.boundaries.interiorBounds(end));
      % Iterate through the interiorBounds array and create the other interior boundaries.
      for i = 1:(nInteriorBounds - 1)
        interiorBounds(i) = InteriorBoundary(config.boundaries.interiorBounds(i));
      end
      % We need to transpose interiorBounds because the preallocated interiorBounds is a row vector,
      % while the prior, non-preallocated, interiorBounds was a column vector. Instead of going through
      % all the instances in which, e.g. size(interiorBounds) is used and fixing it, just transpose it here.
      interiorBounds = interiorBounds.';

      % Assemble obj.boundaries
      obj.boundaries.ffrBounds = ffrBounds;
      obj.boundaries.interiorBounds = interiorBounds;

      % Store list of structs which are the configs of the FFRLayers.
      % Each FFRLayer struct holds the data to make that FFR layer.
      ffrLayerConfigs = config.ffrLayerConfigs;

      % Create FFRLayers
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

      % Aggregate entire FFR fiber data
      obj.fiberData = obj.buildFiberData();
    end

    % Attempt at pre-allocating handle objects (FFR Layers)
%%%      % Create FFRLayers
%%%      % Preallocate the ffrLayers array and create the last FFRLayer in the array.
%%%      lastFFRLayerConfig = ffrLayerConfigs(end);
%%%      % Add the appropriate bounds to the last FFRLayer's config.
%%%      lastFFRLayerConfig.outerBound = obj.boundaries.ffrBounds.outerBound;
%%%      lastFFRLayerConfig.innerBound = obj.boundaries.interiorBounds(end - 1);
%%%      % Preallocate:
%%%      ffrLayers(1, obj.nLayers) = FFRLayer(lastFFRLayerConfig);
%%%      % Iterate through the ffrLayers array and create the other layers.
%%%      for i = 1:(obj.nLayers - 1)
%%%        ffrLayerConfig = ffrLayerConfigs(i);
%%%        if i == 1
%%%          ffrLayerConfig.innerBound = obj.boundaries.ffrBounds.innerBound;
%%%        else
%%%          ffrLayerConfig.innerBound = obj.boundaries.interiorBounds(i - 1);
%%%        end
%%%        %if i == obj.nLayers
%%%          %ffrLayerConfig.outerBound = obj.boundaries.ffrBounds.outerBound;
%%%        %else
%%%        ffrLayerConfig.outerBound = obj.boundaries.interiorBounds(i);
%%%        %end
%%%        ffrLayer = FFRLayer(ffrLayerConfig);
%%%        Debug.msgWithItem("ffrlayer i = " + i, ffrLayer, 1);
%%%        ffrLayers(i) = ffrLayer;
%%%      end
%%%      Debug.msgWithItem("ffrlayer i = 9", ffrLayers(end), 1);
%%%      %Debug.msgWithItem("ffr layers", ffrLayers, 0);
%%%      obj.ffrLayers = ffrLayers;
%%%      Debug.msgWithItem("obj.ffrLayers", obj.ffrLayers, 1);
%%%
%%%      % Aggregate entire FFR fiber data
%%%      obj.fiberData = obj.buildFiberData();
%%%    end
    function fiberData = buildFiberData(obj)
      % Iterate through all the quadrants and combine the fiber data
      % into one large lattice. Because the quadrants already have
      % the correct height and length offset with respect to their
      % position in the FFR (centered at 0,0), the fiber coordinates
      % do not need any manipulation.
      %
      % The quadrant fiber data matrices (n x 3) do not need to
      % be combined with respect to the quadrant's position in
      % the FFR because the ffrFiberData will only ever serve
      % to represent the fibers in the FFR -- any information
      % regarding e.g. a FiberLayer will be accessed through
      % that respective object.
      fiberData = [];
      ffrLayers = obj.ffrLayers;
      for i = 1:size(ffrLayers)
        ffrLayer = ffrLayers(i);
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
      %disp("FFR fiber data:")
      %disp(fiberData)
    end

    function bounds = printBounds(obj)
      bounds = "FFR Bounds:\n-> Left: " + string(obj.ffrBounds.leftBound.bound);
    end
  end
end
