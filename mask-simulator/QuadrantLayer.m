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

      % Create quadrants
      %disp("Num quadrants: " + config.nQuadrants)
      for q = 1:config.nQuadrants
        %disp(q)
        % if q == 3
        %   disp(">> Creating quadrant " + q)
        % end
        quadrant = Quadrant(quadrantConfigs(q));
        % if q == 3
        %   disp(">> Quadrant number 3 data")
        %   disp(quadrant.getFiberData())
        % end
        obj.quadrants = [obj.quadrants; quadrant];
      end

      % Sum quadrant lengths and widths
      %qlWidth = sumWidths();
      qlLength = config.length; % FIXME: get length value from config

      % Aggregate quadrant fiber data
      obj.lattice = obj.makeLattice(config.nQuadrants);
      %disp("Quadrant layer data size: " + size(obj.lattice))

      % Adjust y-values of the fibers to account for:
      %  - bubbblebath_noPlot() centers around [0,0]  -> add half this quadrant layer's width
      %  - quadrant layers below this one             -> add the sum of the previous layers' widths
      obj.lattice = obj.addHeightOffset(config.heightOffset);
    end

    %function width = sumWidths(nQuadrants)
    %  for q
    %end

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

    %function obj = Layer(length, width, minRadius, maxRadius, density, optional_fiberData)
    %  obj.latticeLength = length*BubblebathFiberLattice.LATTICE_I;
    %  obj.latticeWidth = width*BubblebathFiberLattice.LATTICE_J;
    %  frameSize = [obj.latticeLength, obj.latticeWidth];
    %  minRadius = 4*10^(-6);
    %  maxRadius = 4.01*10^(-6);
    %  density = 0.05;
    %  obj.lattice = BubblebathFiberLattice(frameSize, minRadius, maxRadius, density, optional_fiberData);
    %end

    % Plotting
    %function plotLayer(obj, figure)
      % Plot this layer on a given figure.
    %end

    % GETTERS
    % Any attribute of the lattice should be accessed with a getter.
    %function fiberData = getFiberData(obj)
    %  % Return the bb_data of the lattice.
    %  % fiberData is [xcoord, ycoord, radius].
    %  fiberData = obj.lattice.bb_data;
    %end

    %% Get the axis handle
    %function axisHandle = getAxisHandle(obj)
    %  axisHandle = obj.lattice.bb_axisHandle;
    %end

    %% Get the inner bound y coord value
    %function innerBound = getInnerBound(obj)
    %  innerBound = obj.lattice.innerBound;
    %end

    %% Get the outer bound y coord value
    %function outerBound = getOuterBound(obj)
    %  outerBound = obj.lattice.outerBound;
    %end

    %% Get the left bound x coord value
    %function leftBound = getLeftBound(obj)
    %  leftBound = obj.lattice.leftBound;
    %end

    %% Get the right bound x coord value
    %function rightBound = getRightBound(obj)
    %  rightBound = obj.lattice.rightBound;
    %end
  end
end
