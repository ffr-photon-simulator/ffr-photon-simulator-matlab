classdef QuadrantLayer
  % Stores fiber data representing several quadrants of variable fiber density or radial range.
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
      % Uses a config to create a quadrant layer. The config 'c' is a struct of the form:
      % c.length = quadrant layer length
      % c.width  = quadrant layer width
      % c.heightOffset = sum of widths of quadrant layers below this one
      % c.nQuadrants = number of quadrants
      % c.quadrantConfigs = list of structs defining each quadrant (left to right)
      
      % Store list of structs which are the configs of the actual quadrants.
      quadrantConfigs = config.quadrantConfigs; % [qlist1, qlist2, qlist3, ...]
      obj.nQuadrants = config.nQuadrants;

      % Create quadrants
      % Preallocate the array and create the last Quadrant in the array.
      quadrants(1, single(obj.nQuadrants)) = Quadrant(quadrantConfigs(end));
      for q = 1:single(obj.nQuadrants - 1)
        quadrants(q) = Quadrant(quadrantConfigs(q));
      end
      % Transpose the row vector to avoid rewriting other code.
      obj.quadrants = quadrants.';

      % Set quadrant layer length and width
      obj.qlLength = config.length;
      obj.qlWidth = config.width;

      % Sum number of fibers
      obj.nFibers = sum([obj.quadrants.nFibers]);

      % Bound values
      obj.innerBound = config.heightOffset;
      obj.outerBound = obj.innerBound + obj.qlWidth;

      % Aggregate quadrant fiber data
      obj.lattice = obj.makeLattice(obj.nQuadrants);

      % Adjust y-values of the fibers to account for:
      %  - bubbblebath_noPlot() centers around [0,0]  -> add half this quadrant layer's width
      %  - quadrant layers below this one             -> add the sum of the previous layers' widths
      obj.lattice = obj.addHeightOffset(config.heightOffset);
    end

    function lattice = addHeightOffset(obj, offset)
      % Add a height offset to this quadrant layer
      lattice = obj.lattice;
      lattice(:,2) = lattice(:,2) + offset;
    end

    function lattice = makeLattice(obj, nQuadrants)
      % Add the fiber data from each quadrant to this quadrant layer.
      lattice = nan(obj.nFibers, 3);
      for qNum = 1:nQuadrants
        fiberData = obj.quadrants(qNum).getFiberData();
        % The function which maps a fiber in a quadrant defined
        % by its index in the quarant qIdx and the index in the
        % iteration through all the quadrants qNum is:
        %
        % latticeIdx(qIdx, qNum) = nQFibers*(qNum - 1) + qIdx;
        %
        % For example, assume nQFibers = 5 and there are 5 quadrants in total:
        % latticeIdx(1, 1)       = 5*(1-1) + 1 = 1;
        % latticeIdx(1, 2)       = 5*(2-1) + 1 = 6;
        % latticeIdx(2, 2)       = 5*(2-1) + 2 = 7;
        % latticeIdx(5, 4)       = 5*(4-1) + 5 = 20;
        % latticeIdx(5, 5)       = 5*(5-1) + 5 = 25;

        % Get the number of fibers in the current quadrant.
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
