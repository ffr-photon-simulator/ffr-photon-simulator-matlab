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

  properties (Constant)
    % The abs(y step) of reflected photons can never be greater than the
    % initial abs(y step). So make this range half of the default y step.
    range = Defaults.innerToOuterYStep / 2; % already positive
  end

  properties
    % The boundary's coordinate. Only one (x or y) will have a value
    lowerBound
    upperBound

    % Sets of the IDs of each photon that crossed the boundary in either direction
    % at least once. Use this to know whether to count a crossing as a repeat, and
    % benefit from the O(1) access since there are many photons.
    repeatsToInnerIDs = java.util.HashSet;
    repeatsToOuterIDs = java.util.HashSet;
  end

  methods
    function obj = InteriorBoundary(bound)
      % TODO Verify constructors work this way (assign value to superclass properties)
      obj = obj@Boundary(bound);
      obj.lowerBound = bound - obj.range;
      obj.upperBound = bound + obj.range;
    end

    function addCrossing(obj, photon, direction)
      % Increment the following counts:
      %  - total count
      %  - toInner or toOuter
      %  - repeatsToInner or repeatsToOuter, if necessary
      id = photon.id;
      yStep = photon.yStep;
      obj.increment(obj.count);
      if yStep < 0 % crossing outer -> inner
        obj.increment(obj.toInner);
        if ~ obj.repeatsToInnerIDs.contains(id)
          obj.repeatsToInnerIDs.add(id);
        end
      else
        obj.increment(obj.toOuter);
        if ~ obj.repeatsToOuterIDs.contains(id)
          obj.repeatsToOuterIDs.add(id);
        end
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
      data.toOuter = obj.toOuter;
      % Get size of repeats Hash Sets
      data.repeatsToInner = obj.repeatsToInnerIDs.size;
      data.repeatsToOuter = obj.repeatsToOuterIDs.size;
      data.repeats = data.repeatsToInner + data.repeatsToOuter;
    end
  end
end
