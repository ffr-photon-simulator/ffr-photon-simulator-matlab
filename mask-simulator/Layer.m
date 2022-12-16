classdef Layer
  properties
    latticeLength
    latticeWidth
    lattice
  end

  methods
    function obj = Layer(length, width, minRadius, maxRadius, density, optional_fiberData)
      obj.latticeLength = length*BubblebathFiberLattice.LATTICE_I;
      obj.latticeWidth = width*BubblebathFiberLattice.LATTICE_J;
      frameSize = [obj.latticeLength, obj.latticeWidth];
      minRadius = 4*10^(-6);
      maxRadius = 4.01*10^(-6);
      density = 0.05;
      obj.lattice = BubblebathFiberLattice(frameSize, minRadius, maxRadius, density, optional_fiberData);
    end

    % GETTERS
    % Any attribute of the lattice should be accessed with a getter.
    function fiberData = getFiberData(obj)
      % Return the bb_data of the lattice.
      % fiberData is [xcoord, ycoord, radius].
      fiberData = obj.lattice.bb_data;
    end

    function axisHandle = getAxisHandle(obj)
      axisHandle = obj.lattice.bb_axisHandle;
    end

    function innerBound = getInnerBound(obj)
      innerBound = obj.lattice.innerBound;
    end

    function outerBound = getOuterBound(obj)
      outerBound = obj.lattice.outerBound;
    end

    function leftBound = getLeftBound(obj)
      leftBound = obj.lattice.leftBound;
    end

    function rightBound = getRightBound(obj)
      rightBound = obj.lattice.rightBound;
    end
  end
end
