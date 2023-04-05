classdef InteriorBoundary < Boundary
  properties
  end

  methods
    function obj = InteriorBoundary(bound)
      if nargin == 0
        bound = 0;
      end
      obj = obj@Boundary(bound);
    end

    function addCrossing(obj, photon, direction)
      id = photon.id;
      yStep = photon.yStep;
      %Debug.msg("Adding interior crossing.", 1);
      obj.count = obj.count + 1;
      if yStep < 0 % crossing outer -> inner
        obj.incrementToInner();
      else
        obj.incrementToOuter();
      end
    end

    function plot(obj, axisHandle)
      % ax, y=bound, style, label
      yline(axisHandle, obj.bound, Defaults.interiorBoundStyle, 'LineWidth', Defaults.interiorBoundWeight);
    end

    function data = getCountData(obj)
      data = struct();
      % Total counts
      data.count = obj.count;
      data.toInner = obj.toInner;
      %data.toOuter = obj.toOuter;
      % Get size of repeats Hash Sets
      %data.repeatsToInner = obj.repeatsToInnerIDs.size;
      %data.repeatsToOuter = obj.repeatsToOuterIDs.size;
      %data.repeats = data.repeatsToInner + data.repeatsToOuter;
    end

    function printCrossingInfo(obj)
      m1 = "Interior Bound at " + obj.bound + " w/ total crossings = " + obj.count;
      %Debug.msg(m1, 1);
      m2 = " - outer to inner crossings: " + obj.toInner;
      %Debug.msg(m2, 1);
    end

  end
end
