classdef Quadrant
  % A data class representing a quadrant in the lattice.
  % Variable names are copied from bubblebath_noPlot
  % when possible to make the connection clear.
  %
  % The constructor runs bubblebath_noPlot to get the
  % fiber data (also receives the config struct).

  properties
    minRadius
    maxRadius

    bb_struct = struct();
    bb_struct_out % the struct returned from bubblebath_noPlot

    bb_frameSize
    bb_density

    bb_data
  end

  methods
    function obj = Quadrant(frameSize, minRadius, maxRadius, density)
      obj.minRadius = minRadius;
      obj.maxRadius = maxRadius;

      obj.bb_struct.frameSize      = frameSize; % [length, width], centered at [0,0].
      obj.bb_struct.circSize       = [minRadius, maxRadius];
      obj.bb_struct.nSizes         = 10; % number of discrete radii in interval
      obj.bb_struct.maxCircsPerRad = 500;
      obj.bb_struct.maxIt          = 200;
      obj.bb_struct.edgeType       = 1; % all inside frame
      obj.bb_struct.density        = density; % not yet sure what the "density" does in bubblebath.m
      obj.bb_struct.overlap        = QuadrantLattice.F_MIN_SEPARATION;
      obj.bb_struct.overlapType    = 'absolute';
      obj.bb_struct.drawFrame      = true;

      [obj.bb_data, obj.bb_struct_out] = bubblebath_noPlot(obj.bb_struct);
    end
  end
end
