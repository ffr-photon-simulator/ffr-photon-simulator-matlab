classdef FFRLayer
  properties
    quadrantLayers = [];
    lattice = []; % fiber data
    latticeWidth
    latticeLength
  end

  methods
    function obj = FFRLayer(config)
      % Uses a config to create quadrant layers. The config 'c' is a struct of the form:
      % c.nQLayers = number of quadrant layers
      % c.layerType = type of layer ('inner, interior, filtering, or exterior')
      % c.qLayerConfigs = list of structs defining each quadrant layer

      % Store list of structs which are the configs of the quadrant layers.
      % Each quadrant layer struct holds the data to make that quadrant layer.
      qLayerConfigs = config.quadrantLayerConfigs; % [struct1, struct2, struct3, ...]
      %disp("> ffr layer constructor qlayer configs")
      %disp(qLayerConfigs)

      % Create QuadrantLayers
      for q = 1:config.nQLayers
        % if q == 3
        %   disp("")
        %   disp("> Create quadrant layer " + q)
        % end
        quadrantLayer = QuadrantLayer(qLayerConfigs(q));
        % if q == 3
        %   disp("> Quadrant layer 3 data")
        %   disp(quadrantLayer.getFiberData())
        % end
        obj.quadrantLayers = [obj.quadrantLayers; quadrantLayer];
      end

      %disp("> ffrlayer constructor qlayers")
      %disp(obj.quadrantLayers)

      % Aggregate fiber data from the quadrant layers
      obj.lattice = obj.makeLattice(config.nQLayers);
      %disp("FFR Layer lattice")
      %disp(obj.lattice)
      %disp("")
    end

    function lattice = makeLattice(obj, nLayers)
      % Add the fiber data from each quadrant layer to this ffr layer.
      lattice = [];
      for n = 1:nLayers
        lattice = [lattice; obj.quadrantLayers(n).getFiberData()];
        %disp("Quadrant layer " + n + " data:")
        %disp(obj.quadrantLayers(n).getFiberData())
      end
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
    %  % Plot this layer on a given figure.
    %end

    %% GETTERS
    %% Any attribute of the lattice should be accessed with a getter.
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
