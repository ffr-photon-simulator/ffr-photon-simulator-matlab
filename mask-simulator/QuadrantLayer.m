classdef QuadrantLayer
  % Stores fiber data representing several quadrants of variable fiber density or radial range.
  properties
    quadrants = [];
    lattice = [];
    qlWidth
    qlLength
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

    end
    end

    % Plotting
    function plotLayer(obj, figure)
      % Plot this layer on a given figure.
    end

    % GETTERS
    % Any attribute of the lattice should be accessed with a getter.
    function fiberData = getFiberData(obj)
      % Return the bb_data of the lattice.
      % fiberData is [xcoord, ycoord, radius].
      fiberData = obj.lattice.bb_data;
    end

    % Get the axis handle
    function axisHandle = getAxisHandle(obj)
      axisHandle = obj.lattice.bb_axisHandle;
    end

    % Get the inner bound y coord value
    function innerBound = getInnerBound(obj)
      innerBound = obj.lattice.innerBound;
    end

    % Get the outer bound y coord value
    function outerBound = getOuterBound(obj)
      outerBound = obj.lattice.outerBound;
    end

    % Get the left bound x coord value
    function leftBound = getLeftBound(obj)
      leftBound = obj.lattice.leftBound;
    end

    % Get the right bound x coord value
    function rightBound = getRightBound(obj)
      rightBound = obj.lattice.rightBound;
    end
  end
end
