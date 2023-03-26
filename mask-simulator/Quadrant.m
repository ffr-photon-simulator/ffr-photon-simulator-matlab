classdef Quadrant
  % A data class representing a quadrant in a quadrant layer.
  % Variable names are copied from bubblebath_noPlot
  % when possible to make the connection clear.
  %
  % The constructor runs bubblebath_noPlot to get the
  % fiber data (also receives the config struct).
  properties (Constant)
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6); % convenient x-axis basis for lattice length
    LATTICE_J = 10*10^(-6); % convenient y-axis basis for lattice width
  end

  properties
    minRadius
    maxRadius
    density
    frameSize % quadrant size
    length
    width

    bb_struct = struct();

    % Output of bubblebath_noPlot()
    bb_struct_out % the struct returned from bubblebath_noPlot
    bb_data % ([xcoord ycoord radius])

    leftBound
    rightBound
    outerBound
    innerBound
  end

  methods
    function obj = Quadrant(config)
      % The config 'c' is a struct of the form:
      % c.minRadius = minimum fiber radius
      % c.maxRadius = maximum fiber radius
      % c.frameSize = quadrant size
      % c.density   = fiber density
      % c.lengthOffset = left bound x coordinate
      % c.heightOffset = bottom bound y coordinate

      if nargin > 0
        % Store the user-defined values
        obj.minRadius = config.minRadius;
        obj.maxRadius = config.maxRadius;
        obj.frameSize = config.frameSize;
        obj.length    = config.frameSize(1);
        obj.width     = config.frameSize(2);
        obj.density   = config.density;

        % Set other values necessary for bubblebath_noPlot().
        obj.bb_struct.frameSize      = obj.frameSize; % [length, width], centered at [0,0].
        obj.bb_struct.circSize       = [obj.minRadius, obj.maxRadius];
        obj.bb_struct.nSizes         = 5; % number of discrete radii in interval
        obj.bb_struct.maxCircsPerRad = 3;
        obj.bb_struct.maxIt          = 200;
        obj.bb_struct.edgeType       = 1; % all inside frame
        obj.bb_struct.density        = obj.density; % not yet sure what the "density" does in bubblebath.m
        obj.bb_struct.overlap        = obj.F_MIN_SEPARATION;
        obj.bb_struct.overlapType    = 'absolute';
        obj.bb_struct.drawFrame      = true;

        % Run bubblebath_noPlot() and store the output.
        [obj.bb_data, obj.bb_struct_out] = bubblebath_noPlot(obj.bb_struct);
        obj.nFibers = size(obj.bb_data, 1);

        % Add the length offset to the x-values in bb_data and store the data.
        obj.bb_data = obj.addLengthOffset(config.lengthOffset);
        obj.bb_data = obj.addHeightOffset(config.heightOffset);

        % Determine the quadrant's boundary values

        % Left bound: the length offset, as noted below, starts at the quadrant layer's left bound and
        % adds the length of any previous quadrants along with half the length of this quadrant.
        % The left bound of this quadrant is just the QL's left bound plus the length of evous
        % quadrants, so we subtract half the length of this quadrant from the lengthOffset.
        obj.leftBound = config.lengthOffset - (config.frameSize(1) / 2);

        % Right bound: the left bound plus the quadrant's length
        obj.rightBound = obj.leftBound + obj.length;

        % Inner bound: the height offset, but minus half the quadrant's width because
        % we've already added half the quadrant layer's width to the height offset
        % (see config.m, about line 70).
        obj.innerBound = config.heightOffset - (obj.width / 2);

        % Outer bound: the height offset plus the quadrant's width
        obj.outerBound = obj.innerBound + obj.width;
      end
    end

    function data = addLengthOffset(obj, offset)
      % Add a length offset to this quadrant. The offset is equal to
      % the leftmost x coordinate of the quadrant layer, divided by 2
      % and negated, then plus the length of any previous quadrants
      % in the layer, and plus half the length of the current quadrant
      % (because the current quadrant is _centered_ on [0,0]).
      data = obj.bb_data;
      data(:,1) = data(:,1) + offset;
    end

    function data = addHeightOffset(obj, offset)
      data = obj.bb_data;
      data(:,2) = data(:,2) + offset;
    end

    % GETTERS
    function data = getFiberData(obj)
      data = obj.bb_data;
    end
  end
end
