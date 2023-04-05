classdef QuadrantLayer
  properties
    quadrants
    nQuadrants
    lattice = [];
    qlWidth
    qlLength
    outerBound
    innerBound
    nFibers
  end

  methods
    function obj = QuadrantLayer(config)
      quadrantConfigs = config.quadrantConfigs; % [qlist1, qlist2, qlist3, ...]
      obj.nQuadrants = config.nQuadrants;

      quadrants(1, single(obj.nQuadrants)) = Quadrant(quadrantConfigs(end));
      for q = 1:single(obj.nQuadrants - 1)
        quadrants(q) = Quadrant(quadrantConfigs(q));
      end
      obj.quadrants = quadrants.';

      obj.qlLength = config.length;
      obj.qlWidth = config.width;

      obj.nFibers = sum([obj.quadrants.nFibers]);

      obj.innerBound = config.heightOffset;
      obj.outerBound = obj.innerBound + obj.qlWidth;

      obj.lattice = obj.makeLattice(obj.nQuadrants);

      obj.lattice = obj.addHeightOffset(config.heightOffset);
    end

    function lattice = addHeightOffset(obj, offset)
      lattice = obj.lattice;
      lattice(:,2) = lattice(:,2) + offset;
    end

    function lattice = makeLattice(obj, nQuadrants)
      lattice = nan(obj.nFibers, 3);
      for qNum = 1:nQuadrants
        fiberData = obj.quadrants(qNum).getFiberData();
        nQFibers = size(fiberData, 1);
        for qIdx = 1:nQFibers
          latticeIdx = nQFibers*(qNum - 1) + qIdx;
          lattice(latticeIdx,:,:) = fiberData(qIdx,:,:);
        end
      end
    end

    function data = getFiberData(obj)
      data = obj.lattice;
    end

  end
end
