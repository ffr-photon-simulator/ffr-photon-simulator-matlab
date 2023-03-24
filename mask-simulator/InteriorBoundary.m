classdef InteriorBoundary < Boundary
  % Represents the boundary between two FFR Layers.
  % Keeps track of how many photons have crossed the
  % boundary, and from which direction. Also keeps
  % track of repeated photon crossings.
  %
  % Store the count data and put it in a struct
  % when the user requests it. Do not keep track
  % of the number of repeats, instead add the sizes
  % of the two repeated photon ID hash sets when
  % the user requests the data.
  properties
    % Sets of the IDs of each photon that crossed the boundary in either direction
    % at least once. Use this to know whether to count a crossing as a repeat, and
    % benefit from the O(1) access since there are many photons.
    %repeatsToInnerIDs = java.util.HashSet;
    %repeatsToOuterIDs = java.util.HashSet;
  end

  methods
    function obj = InteriorBoundary(bound)
      obj = obj@Boundary(bound);
    end

    function addCrossing(obj, photon, direction)
      % Increment the following counts:
      %  - toInner or toOuter
      id = photon.id;
      yStep = photon.yStep;
      Debug.msg("Adding interior crossing.", 1);
      obj.count = obj.count + 1;
      if yStep < 0 % crossing outer -> inner
        obj.incrementToInner();
      else
        obj.incrementToOuter();
      end
    end

    function plot(obj, axisHandle)
      % ax, y=bound, style, label
      yline(axisHandle, obj.bound, Defaults.interiorBoundStyle, obj.bound, 'LineWidth', Defaults.interiorBoundWeight);
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
      Debug.msg(m1, 1);
      m2 = " - outer to inner crossings: " + obj.toInner;
      Debug.msg(m2, 1);
      %m2 = "- outer to inner crossings: " + data.toInner + "\n  - repeated: " + data.repeatsToInner;
      %m3 = "- inner to outer crossings: " + data.toOuter + "\n  - repeated: " + data.repeatsToOuter;
      %Defaults.debugMessage(m2, 0);
      %Defaults.debugMessage(m3, 0);
    end
  end
end
