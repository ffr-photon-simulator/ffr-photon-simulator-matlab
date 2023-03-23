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

    function addCrossing(obj, photon, direction)
      % Increment the following counts:
      %  - toInner or toOuter
      yStep = photon.yStep;
      Defaults.debugMessage("Adding FFR bound crossing.", 0);
      Defaults.debugMessage("photon y step: " + yStep, 1);
      if yStep < 0 % crossing outer -> inner
        Defaults.debugMessage("inc to inner", 1);
        obj.incrementToInner();
      else
        Defaults.debugMessage("inc to outer", 1);
        obj.incrementToOuter();
      end
    end

    %function addCrossing(obj, photon, direction)
    %  % Increment the following counts:
    %  %  - total count
    %  Defaults.debugMessage("FFR Bound Count: " + obj.count, 1);
    %  %incrementCount@Boundary(obj);
    %  obj.count = obj.count + 1;
    %  Defaults.debugMessage("FFR Bound Count incremented: " + obj.count, 1);
    %end

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
