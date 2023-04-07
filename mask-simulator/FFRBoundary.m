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
      obj = obj@Boundary(bound);
      obj.type = type;
    end

    function addCrossing(obj, photon, direction)
      % Increment the following counts:
      %  - toInner or toOuter
      yStep = photon.yStep;
      %Debug.msg("Adding FFR bound crossing.", 1);
      if yStep < 0 % crossing outer -> inner
        obj.incrementToInner();
      else
        obj.incrementToOuter();
      end
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
      data.type = obj.type;
    end

    function printCrossingInfo(obj)
      msg = "\nFFRBound type: " + obj.type + "\n - total crossings: " + obj.count;
      %Debug.msg(msg, 1);
    end
  end
end
