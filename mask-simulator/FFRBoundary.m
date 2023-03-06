classdef FFRBoundary < Boundary
  % Represents the exterior boundaries of the FFR.
  % Keeps track of how many photons have crossed the boundary.
  % Exterior boundaries are: left, right, outer, inner.
  % Store the count data and put it in a struct  when the user requests it.

  properties
    type % left, right, outer, or inner
  end

  methods
    function obj = FFRBoundary(bound, type)
      % TODO Verify constructors work this way (assign value to superclass properties)
      obj = obj@Boundary(bound);
      obj.type = type;
    end

    %function crossed = hasCrossed(obj, photon)
    %  x = photon.x;
    %  y = photon.y;
    %  if obj.type == 'left' && x <= obj.bound
    %    crossed = true;
    %  elseif obj.type == 'right' && x >= obj.bound
    %    crossed = true;
    %  elseif obj.type == 'outer' && y >= obj.bound
    %    crossed = true;
    %  elseif obj.type == 'inner' && y <= obj.bound
    %    crossed = true;
    %  else
    %    crossed = false;
    %  end
    %end

    function addCrossing(obj, photon)
      % Increment the following counts:
      %  - total count
      obj.increment(obj.count);
    end

    function plot(obj, axisHandle)
      if isequal(obj.type, 'inner') || isequal(obj.type, 'outer')
        yline(axisHandle, obj.bound, Defaults.ffrBoundStyle, obj.bound, 'LineWidth', Defaults.ffrBoundWeight);
      else
        xline(axisHandle, obj.bound, Defaults.ffrBoundStyle, obj.bound, 'LineWidth', Defaults.ffrBoundWeight);
      end
    end

    function data = getCountData(obj)
      data = struct();
      data.count = obj.count;
    end
  end
end