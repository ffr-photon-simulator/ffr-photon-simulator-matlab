classdef Quadrant
  properties (Constant)
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6);
    LATTICE_J = 10*10^(-6);
  end

  properties
    minRadius
    maxRadius
    density
    frameSize % quadrant size
    length
    width
    nFibers

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

      if nargin > 0
        obj.minRadius = config.minRadius;
        obj.maxRadius = config.maxRadius;
        obj.frameSize = config.frameSize;
        obj.length    = config.frameSize(1);
        obj.width     = config.frameSize(2);
        obj.density   = config.density;

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

        [obj.bb_data, obj.bb_struct_out] = bubblebath_noPlot(obj.bb_struct);
        obj.nFibers = size(obj.bb_data, 1);

        obj.bb_data = obj.addLengthOffset(config.lengthOffset);
        obj.bb_data = obj.addHeightOffset(config.heightOffset);

        obj.leftBound = config.lengthOffset - (config.frameSize(1) / 2);

        obj.rightBound = obj.leftBound + obj.length;

        obj.innerBound = config.heightOffset - (obj.width / 2);

        obj.outerBound = obj.innerBound + obj.width;
      end
    end

    function data = addLengthOffset(obj, offset)
      data = obj.bb_data;
      data(:,1) = data(:,1) + offset;
    end

    function data = addHeightOffset(obj, offset)
      data = obj.bb_data;
      data(:,2) = data(:,2) + offset;
    end

    function data = getFiberData(obj)
      data = obj.bb_data;
    end

  end
end
