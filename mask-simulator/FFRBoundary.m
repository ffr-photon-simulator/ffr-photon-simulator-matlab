classdef FFRBoundary < Boundary
  properties
    type % left, right, outer, or inner
  end

  methods
    function obj = FFRBoundary(bound, type)
      obj = obj@Boundary(bound);
      obj.type = type;
    end

    function addCrossing(obj, photon, direction)
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
        yline(axisHandle, obj.bound, Defaults.ffrBoundStyle, 'LineWidth', Defaults.ffrBoundWeight);
      else
        xline(axisHandle, obj.bound, Defaults.ffrBoundStyle, 'LineWidth', Defaults.ffrBoundWeight);
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
