classdef Boundary < handle
  properties
    bound
    count = 0; % total crossings count
    % Counts of photons traveling from outer layer to inner layer (negative y step).
    toInner = 0;
    % Counts of photons traveling from inner layer to outer layer (positive y step).
    toOuter = 0;
  end

  methods
    function obj = Boundary(bound)
      if nargin > 0
        obj.bound = bound;
      end
    end

    function incrementCount(obj)
      obj.count = obj.count + 1;
    end

    function incrementToInner(obj)
      obj.toInner = obj.toInner + 1;
    end

    function incrementToOuter(obj)
      obj.toOuter = obj.toOuter + 1;
    end

    function bound = getBound(obj)
      bound = obj.bound;
    end

  end
end
