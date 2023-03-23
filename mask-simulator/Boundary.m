classdef Boundary < handle
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
  %
  %
  % There are two types of boundaries.
  % 1. FFR boundaries. These represent the edges of the FFR: left, right, outer, inner.
  %    The left and right boundaries are defined by an x value, and the outer and inner
  %    boundaries are defined by a y-value. If a photon crosses any of these boundaries,
  %    it has left the simulation and the ray tracer moves on to the next photon.
  % 2. Interior boundaries. These represent the boundaries between interior layers, and
  %    are defined by a y-value plus/minus one general photon step. If a photon is inside
  %    this range, it must have crossed the boundary, and its direction of travel (positive
  %    or negative), is used to determine which way it crossed.
  %
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
      obj.bound = bound;
    end

    function incrementCount(obj)
      % Avoid the verbosity that comes with:
      % obj.toOuter = obj.toOuter + 1;
      %value = value + 1;
      obj.count = obj.count + 1;
    end

    function incrementToInner(obj)
      obj.toInner = obj.toInner + 1;
    end

    function incrementToOuter(obj)
      obj.toOuter = obj.toOuter + 1;
    end

    % GETTERS
    function bound = getBound(obj)
      bound = obj.bound;
    end
  end
end
