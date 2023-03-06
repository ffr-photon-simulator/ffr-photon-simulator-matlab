classdef FFR
  % A class representing an FFR.
  properties
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

      % Store list of structs which are the configs of the FFRLayers.
      % Each FFRLayer struct holds the data to make that FFR layer.
      ffrLayerConfigs = config.ffrLayerConfigs;

      % Create FFRLayers
      for l = 1:config.nLayers
        %disp("Create FFRLayer " + q)
        ffrLayer = FFRLayer(ffrLayerConfigs(l));
        obj.ffrLayers = [obj.ffrLayers; ffrLayer];
      end

      % Create Boundaries
      % FFR bounds
      ffrBounds = struct();
      ffrBounds.leftBound = FFRBoundary(config.boundaries.ffrBounds.leftBound, 'left');
      ffrBounds.rightBound = FFRBoundary(config.boundaries.ffrBounds.rightBound, 'right');
      ffrBounds.innerBound = FFRBoundary(config.boundaries.ffrBounds.innerBound, 'inner');
      ffrBounds.outerBound = FFRBoundary(config.boundaries.ffrBounds.outerBound, 'outer');
      obj.ffrBounds = ffrBounds;

      % Interior bounds
      interiorBounds = [];
      for i = 1:size(config.boundaries.interiorBounds)
        interiorBounds = [interiorBounds; InteriorBoundary(config.boundaries.interiorBounds(i))];
      end
      Defaults.debugMessage("Interior bounds in FFR constructor", 1);
      obj.boundaries.ffrBounds = ffrBounds;
      obj.boundaries.interiorBounds = interiorBounds;

      % Aggregate entire FFR fiber data
      obj.fiberData = obj.buildFiberData();
    end

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
      %disp("FFR Bounds:")
      %disp("-> Left: "  + obj.ffrBounds.leftBound.bound)
      %disp("-> Right: " + obj.ffrBounds.rightBound.bound)
      %disp("-> Outer: " + obj.ffrBounds.outerBound.bound)
      %disp("-> Inner: " + obj.ffrBounds.innerBound.bound)
      %disp("")
    end
  end
end
