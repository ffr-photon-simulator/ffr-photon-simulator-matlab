classdef QuadrantLattice
  properties (Constant)
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6); % convenient x-axis basis (lattice length)
    LATTICE_J = 10*10^(-6); % convenient y-axis basis (lattice width)
  end

  properties
    nQuadrants
    quadrants = []; % array of quadrants, indexed left -> right
    fiberData = []; % [xcoord ycoord radius], from bubblebath
  end

  methods
    % Constructor
    function obj = QuadrantLattice(quadrantsConfig)
      % Create the quadrants, each with its own config.
      obj.nQuadrants = size(quadrantsConfig);
      for i = obj.nQuadrants
        quadrantConfig = quadrantsConfig{i};
        quadrant = Quadrant(quadrantConfig);
        obj.quadrants = [quadrants; quadrant];
      end

      % Concatenate the fiber data from each quadrant.
      for i = obj.nQuadrants
        obj.fiberData = [obj.fiberData; obj.quadrants(i).bb_data];
      end

      % Overwrite the current fiberData if given other fiber data to use.
      if ~isempty(optional_fiberData)
        obj.bb_data = optional_fiberData;
      end
      % Plot the centers of the fibers as points.
      % plot(obj.bb_axisHandle, obj.bb_data(:,1), obj.bb_data(:,2), 'k.','MarkerSize',5);
    end

    function fiberData = get.bb_data(obj)
      fiberData = obj.bb_data;
    end

    function s = coordToString(obj, coords)
      s = string(coords(1)) + ", " + string(coords(2));
    end
  end
end
