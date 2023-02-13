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

    bb_struct = struct();
    bb_struct_out % the struct returned from bubblebath_noPlot

    bb_frameSize
    bb_density

    bb_data
  end

  methods
    function obj = Quadrant(config)
      % The config 'c' is a struct of the form:
      % c.minRadius = minimum fiber radius
      % c.maxRadius = maximum fiber radius
      % c.frameSize = quadrant size
      % c.density   = fiber density

      % Store the user-defined values
      obj.minRadius = config.minRadius;
      obj.maxRadius = config.maxRadius;
      obj.frameSize = config.frameSize;
      obj.density   = config.density;

      obj.bb_struct.nSizes         = 10; % number of discrete radii in interval
      obj.bb_struct.maxCircsPerRad = 500;
      obj.bb_struct.maxIt          = 200;
      obj.bb_struct.edgeType       = 1; % all inside frame
      obj.bb_struct.density        = density; % not yet sure what the "density" does in bubblebath.m
      obj.bb_struct.overlap        = QuadrantLattice.F_MIN_SEPARATION;
      obj.bb_struct.overlapType    = 'absolute';
      obj.bb_struct.drawFrame      = true;

      [obj.bb_data, obj.bb_struct_out] = bubblebath_noPlot(obj.bb_struct);
    function data = addLengthOffset(obj, offset)
      % Add a length offset to this quadrant
      data = obj.bb_data;
      data(:,1) = data(:,1) + offset;
    end

    end
  end
end
