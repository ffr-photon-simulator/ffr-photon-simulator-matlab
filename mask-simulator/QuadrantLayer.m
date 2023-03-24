classdef QuadrantLayer
  % Stores fiber data representing several quadrants of variable fiber density or radial range.
  properties
    quadrants = [];
    lattice = [];
    qlWidth
    qlLength
    outerBound
    innerBound
  end

  methods
    function obj = QuadrantLayer(config)
      % Uses a config to create a quadrant layer. The config 'c' is a struct of the form:
      % c.length = quadrant layer length
      % c.width  = quadrant layer width
      % c.heightOffset = sum of widths of quadrant layers below this one
      % c.nQuadrants = number of quadrants
      % c.quadrantConfigs = list of structs defining each quadrant (left to right)
      
      % Store list of structs which are the configs of the actual quadrants.
      quadrantConfigs = config.quadrantConfigs; % [qlist1, qlist2, qlist3, ...]

      % Create quadrants
      for q = 1:config.nQuadrants
        quadrant = Quadrant(quadrantConfigs(q));
        obj.quadrants = [obj.quadrants; quadrant];
      end

      % Sum quadrant lengths and widths
      obj.qlLength = config.length;
      obj.qlWidth = config.width;

      % Bound values
      obj.innerBound = config.heightOffset;
      obj.outerBound = obj.innerBound + obj.qlWidth;

      % Aggregate quadrant fiber data
      obj.lattice = obj.makeLattice(config.nQuadrants);

      % Adjust y-values of the fibers to account for:
      %  - bubbblebath_noPlot() centers around [0,0]  -> add half this quadrant layer's width
      %  - quadrant layers below this one             -> add the sum of the previous layers' widths
      obj.lattice = obj.addHeightOffset(config.heightOffset);
    end

    function lattice = addHeightOffset(obj, offset)
      % Add a height offset to this quadrant layer
      lattice = obj.lattice;
      lattice(:,2) = lattice(:,2) + offset;
    end

    function lattice = makeLattice(obj, nQuadrants)
      % Add the fiber data from each quadrant to this quadrant layer.
      lattice = [];
      for n = 1:nQuadrants
        lattice = [lattice; obj.quadrants(n).getFiberData()];
      end
    end

    function data = getFiberData(obj)
      data = obj.lattice;
    end
  end
end
