classdef BubblebathFiberLattice
  properties (Constant)
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6); % convenient x-axis basis (lattice length)
    LATTICE_J = 10*10^(-6); % convenient y-axis basis (lattice width)
  end

  properties (Access = public)
    bb_struct = struct();

    minRadius
    maxRadius

    % Output of bubblebath.m
    bb_data % ([xcoord ycoord radius])
    bb_circHandles
    bb_frame
    bb_struct_out
    bb_axisHandle

    innerBound
    outerBound
    leftBound
    rightBound
  end

  methods
    % Constructor
    function obj = BubblebathFiberLattice(frameSize, minRadius, maxRadius, density)
      obj.minRadius = minRadius;
      obj.maxRadius = maxRadius;

      obj.bb_struct.frameSize      = frameSize; % [length, width], centered at [0,0].
      obj.bb_struct.circSize       = [minRadius, maxRadius];
      obj.bb_struct.nSizes         = 10; % default 25
      obj.bb_struct.maxCircsPerRad = 500;
      obj.bb_struct.maxIt          = 200;
      obj.bb_struct.edgeType       = 1; % all inside frame
      obj.bb_struct.density        = density; % not yet sure what the "density" does in bubblebath.m
      obj.bb_struct.overlap        = BubblebathFiberLattice.F_MIN_SEPARATION;
      obj.bb_struct.overlapType    = 'absolute';
      obj.bb_struct.drawFrame      = true;

      [obj.bb_data, ~, ~, obj.bb_axisHandle] = bubblebath(obj.bb_struct);
      hold on
      plot(obj.bb_data(:,1), obj.bb_data(:,2), 'k.','MarkerSize',5);


      obj.innerBound = -obj.bb_struct.frameSize(2) / 2;
      obj.outerBound =  obj.bb_struct.frameSize(2) / 2;
      obj.leftBound  = -obj.bb_struct.frameSize(1) / 2;
      obj.rightBound =  obj.bb_struct.frameSize(1) / 2;
      %disp(obj.innerBound)
      %disp(obj.outerBound)
      %disp(obj.leftBound)
      %disp(obj.rightBound)
    end

    function minRadius = get.minRadius(obj)
      minRadius = obj.minRadius;
    end

    function maxRadius = get.maxRadius(obj)
      maxRadius = obj.maxRadius;
    end

    function fiberData = get.bb_data(obj)
      fiberData = obj.bb_data;
    end

    function s = coordToString(obj, coords)
      s = string(coords(1)) + ", " + string(coords(2));
    end
  end
end
