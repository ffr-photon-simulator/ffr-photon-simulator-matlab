classdef Layer
  properties
    % Anything here does not have a getter. Access these directly,
    % but use getters to access what they contain (e.g. attributes).
    latticeLength
    latticeWidth
    lattice
  end

  methods
    function obj = Layer(length, width, minRadius, maxRadius, density)
      obj.latticeLength = length*BubblebathFiberLattice.LATTICE_I;
      obj.latticeWidth = width*BubblebathFiberLattice.LATTICE_J;
      frameSize = [obj.latticeLength, obj.latticeWidth];
      minRadius = 4*10^(-6);
      maxRadius = 4.01*10^(-6);
      density = 0.05;
      obj.lattice = BubblebathFiberLattice(frameSize, minRadius, maxRadius, density);
    end

    % GETTERS
    % Any attribute of the lattice should be accessed with a getter.
    function fiberData = getFiberData(obj)
      % Return the bb_data of the lattice.
      % fiberData is [xcoord, ycoord, radius].
      fiberData = obj.lattice.bb_data;
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
