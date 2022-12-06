classdef RandomBoundedLattice
	% Make the lattice using bubblebath()
  properties (Constant)
    % Units in meters, seconds unless otherwise specified
    incident_photon_wavelength = 2.5 * 10^(-7);

    fiber_diameter             = 4 * 10^(-6); % 4 microns
    fiber_radius               = RandomBoundedLattice.fiber_diameter/2;
    fiber_min_radius           = RandomBoundedLattice.fiber_radius;
    fiber_max_radius           = RandomBoundedLattice.fiber_radius * 1.01; % bubblebath needs min ≠ max
    % Add this to the radius to get the reflection radius for all fibers
    fiber_refl_rad_delta       = RandomBoundedLattice.fiber_radius + RandomBoundedLattice.incident_photon_wavelength/2; % add half-wavelength
    fiber_min_separation       = 2*10^(-6);

    i                         = 10*10^(-6);
    j                         = 10*10^(-6);
    %x_basis_multiplier        = 2; % twice the basis is the horizontal distance between fibers
  end
  properties
    general_photon_step

    % Fiber Lattice
    % 10μm diagonal separation means about 14μm horizontal and vertical separation
    % Divide the horizontal and vertical separation in half, and let these be
    % a basis for laying out the lattice.
    fiber_data % the lattice array

    % Bubblebath struct params
    bb_frameSize
    bb_circSize
    bb_nSizes
    bb_maxCircsPerRad
    bb_maxIt
    bb_edgeType
    bb_density
    bb_overlap
    bb_overlapType
    bb_drawFrame
    bb_frame % handle to rectangular boundary frame

    bb_struct

 % Dimensions in units of fibers
    number_fibers_in_length % integer
    number_fibers_in_width
    x_padding
    y_padding
    lattice_fibers_length % leftmost fiber to rightmost fiber length. Bubblebath frame length.
    lattice_fibers_width  % Bubblebath frame width.
    lattice_length % add padding
    lattice_width
    % num fibers per quadrant

    % Boundary dictionary
    % We need to keep track of how many photons impact each boundary. The boundaries
    % are either defined by a constant x-value or constant y-value.
    boundary_names
    boundary_coords
    boundary_dict % names -> coords
    boundary_impacts % array of counts
    boundary_impacts_dict % names -> counts

    % Photon motion
    incident_photon_x_step = 0;
    incident_photon_y_step
    photonXStep
    photonYStep
    photonPathsCoordArray = [];
  end % properties

  methods
    % Constructor
      function obj = RandomBoundedLattice(lengthMultiplier, widthMultiplier, generalStepMultiplier)
        % Length and width multipliers multiply i and j.
        % Hardcode bubblebath params here for now.
      obj.general_photon_step = (obj.incident_photon_wavelength / 2) / generalStepMultiplier;
      obj.incident_photon_y_step = -obj.general_photon_step;
      obj.photonXStep = obj.incident_photon_x_step;
      obj.photonYStep = obj.incident_photon_y_step;

      %obj.number_fibers_in_length = length;
      %obj.number_fibers_in_width = width;
      obj.x_padding = obj.i;
      obj.y_padding = obj.j;
      obj.lattice_fibers_length = (lengthMultiplier * obj.i); % lattice length w/o padding
      obj.lattice_fibers_width = (widthMultiplier * obj.j); % lattice width w/o padding
      obj.lattice_length = obj.lattice_fibers_length; %obj.lattice_fibers_length + (2 * obj.x_padding);
      obj.lattice_width = obj.lattice_fibers_width; %obj.lattice_fibers_width + (2 * obj.y_padding);

      obj.bb_frameSize   = [obj.lattice_fibers_length obj.lattice_fibers_width]; % [xlength ylength]
      obj.bb_circSize = [RandomBoundedLattice.fiber_radius RandomBoundedLattice.fiber_radius*1.01];
      obj.bb_nSizes = 25; % default 25
      obj.bb_maxCircsPerRad = 5000;
      obj.bb_maxIt = 400;
      obj.bb_edgeType = 1; % all inside frame
      obj.bb_density = 0.001; % not yet sure what the "density" does in bubblebath.m
      obj.bb_overlap = RandomBoundedLattice.fiber_min_separation;
      obj.bb_overlapType = 'absolute';
      obj.bb_drawFrame = true;

      s = struct();
      s.frameSize = obj.bb_frameSize;
      s.circSize = obj.bb_circSize;
      s.nSizes = obj.bb_nSizes;
      s.maxCircsPerRad = obj.bb_maxCircsPerRad;
      s.maxIt = obj.bb_maxIt;
      s.edgeType = obj.bb_edgeType;
      s.density = obj.bb_density;
      s.overlap = obj.bb_overlap;
      s.overlapType = obj.bb_overlapType;
      s.drawFrame = obj.bb_drawFrame;

      obj.bb_struct = s;

	    % Use bubblebath() by Adam Danz
	    % at https://www.mathworks.com/matlabcentral/answers/446114-non-overlapping-random-circles
      % Copied from bubblebath.m documentation:
      % Outputs
      %   * circData: [m x 3] matrix of m circles data showing [xCenter, yCenter, radius].
      %   * circHandles: [m x 1] vector of handles for each line object / circle.
      %   * frame: handle to 'frame' rectangle (GraphicsPlaceHolder if drawFrame is false).
      %   * S: A structure with fields listing all parameters used to reproduce the figure
      %       also including S.rng which is the random number generator state you can use
      %       to reproduce a figure.
      % fiber_data is [xCoord yCoord radius] row for each fiber
      [obj.fiber_data, circHandles, obj.bb_frame, S] = bubblebath(obj.bb_struct);
      %disp("Fiber lattice:\n" + obj.fiber_data)
      % Boundary dictionary
      % We need to keep track of how many photons impact each boundary. The boundaries
      % are either defined by a constant x-value or constant y-value.
      obj.boundary_names  = {'Outer', 'Inner', 'Left', 'Right'};
      obj.boundary_coords = {obj.lattice_width / 2, -obj.lattice_width / 2, -obj.lattice_length/2, obj.lattice_length/2};
      obj.boundary_dict   = containers.Map(obj.boundary_names, obj.boundary_coords);
      obj.boundary_impacts = {0,0,0,0}; % count of number of impacts on each boundary
      obj.boundary_impacts_dict = containers.Map(obj.boundary_names, obj.boundary_impacts);
    end

    function innerBoundCoordArray = rayTraceTowardsInner(obj, initialCoordsArray)
        innerBoundCoordArray = [];
        photonTracker = 1;
        for row = 1:size(initialCoordsArray)
          photonCoords = [ initialCoordsArray(row,1), initialCoordsArray(row,2) ];
          disp("Photon " + photonTracker + " initial coords: " + coordToString(obj, photonCoords))
          photonReflectionTracker = 0;
          % reflected = false;
          atBoundary = false;
          while (atBoundary == false)
            previousPhotonCoords = photonCoords;
            obj.photonPathsCoordArray = [obj.photonPathsCoordArray; photonCoords];
            %disp("paths: ")
            %disp(obj.photonPathsCoordsArray)
            photonCoords = movePhoton(obj, obj.photonXStep, obj.photonYStep, photonCoords);
            % Reflection and boundary checks
            [reflected, reflectedFiberCoords] = obj.checkIfReflected(photonCoords);
            [atBoundary, boundary] = checkIfAtBoundary(obj, photonCoords);
            if atBoundary == true
              disp("At boundary.")
              if boundary == "Inner"
                  innerBoundCoordArray = [innerBoundCoordArray; photonCoords]; % store only inner boundary coords
              end
              % Reset initial steps
              obj.photonXStep = obj.incident_photon_x_step;
              obj.photonYStep = obj.incident_photon_y_step;
              photonReflectionTracker = 0;
              % end current for loop and move to next initial coord
            elseif reflected == true
              disp("Photon " + photonTracker + " reflected off of fiber at: " + coordToString(obj, reflectedFiberCoords))
              photonReflectionTracker = photonReflectionTracker + 1;
              [newXStep, newYStep] = calculateNewSteps(obj, photonCoords, previousPhotonCoords, reflectedFiberCoords);
              obj.photonXStep = newXStep;
              obj.photonYStep = newYStep;
              %disp("    Photon x step: " + obj.photonXStep)
              %disp("    Photon y step: " + obj.photonYStep)
            end
          end
          photonTracker = photonTracker + 1;
        end
    end

    % Photon motion methods
    function [newXStep, newYStep] = calculateNewSteps(obj, reflectionPoint, previousPhotonCoords, reflectedFiberCoords)
     % Find the xstep and ystep of a reflected photon.
     %
     % Reflect the previous photon coordinates across the radius. 
     % Find the line F that goes through the previous photon coordinates and is perpendicular to the radius
     % G which goes through the reflection point on the fiber. The x and y
     % distance from the previous photon coordinates to the intersection point
     % of F and G are the same x and y distances from the intersection point
     % to the new reflected point, by symmetry.
      x_i = previousPhotonCoords(1);
      y_i = previousPhotonCoords(2);
      a = reflectionPoint(1);
      b = reflectionPoint(2);
      fibera = reflectedFiberCoords(1);
      fiberb = reflectedFiberCoords(2);

      m = (b - fiberb)/(a - fibera); % slope of line between reflection point and fiber coords
      %i = b - (m*a); % 
      n = -1/m;                      % slope perpendicular to the radius through the reflection point
      j = y_i - (n*x_i);             % y value to add after reflection

      C = b + (n*x_i) - (m*a) - y_i; % 

      %t = obj.fibers_x_separation_basis;

      %o = linspace(-3*t,3*t,100);
      %p = m*o + i;

      %plot(o,p,'k.','MarkerSize',5);
      % Plot the radius to the point of reflection.
      %plot([reflectionPoint(1) reflectedFiberCoords(1)], [reflectionPoint(2) reflectedFiberCoords(2)],'k.','MarkerSize',15);
      c= (-m*C)/(m^2 + 1);   % x coord of intersection point
      d = (n*c) + j;         % y coord of intersection point

      xNew = x_i + 2*(c-x_i); % x coord of reflected point
      yNew = y_i + 2*(d-y_i); % y coord of reflected point
      %plot([xNew, yNew ],'k.','MarkerSize',10)

      newXStep = xNew - a;
      newYStep = yNew - b;
      %disp("    New x step: " + newXStep)
      %disp("    New y step: " + newYStep)
    end

    function [reflected, reflectedFiberCoords] = checkIfReflected(obj, photonCoords)
    % Check if a photon has reflected off a fiber.
    %
    % Iterate through the fiber lattice and calculate the distance from the photon to
    % each fiber. If that distance is less than the fibers's reflection radius, then
    % the photon has reflected at the current photonCoords.
    %
    % RETURNS
    % reflected: tells the loop whether the photon has reflected; either true or false.
    % reflectedFiberCoords: the coordinates of the fiber off which the photon reflected.
      %for latticeRow = 1:obj.number_fibers_in_width
        for row = 1:size(obj.fiber_data)
          fiberXCoord = obj.fiber_data(row,1);
          fiberYCoord = obj.fiber_data(row,2);
          fiberCoords = [fiberXCoord fiberYCoord];
          fiberReflectionRadius = obj.fiber_data(row,3) + RandomBoundedLattice.fiber_refl_rad_delta;
          photonDistanceToFiber = calculatePhotonDistanceToFiber(obj, photonCoords, fiberCoords);
          if photonDistanceToFiber < fiberReflectionRadius
            %disp("  Photon distance to fiber: " + photonDistanceToFiber)
            reflected = true;
            reflectedFiberCoords = fiberCoords;
            return;
          end
        end
        reflected = false;
        reflectedFiberCoords = [];
      %end
    end

    function newCoords = movePhoton(obj, xStep, yStep, previousCoords)
      % Move the photon in the x and y directions.
      newCoords = [previousCoords(1) + xStep,  previousCoords(2) + yStep];
    end

    function distanceToFiber = calculatePhotonDistanceToFiber(obj, photonCoords, fiberCoords)
      % abs() is technically unnecessary since we square it in the pythagorean theorem,
      % but keep it for clarity
      xDistanceToFiber = abs(fiberCoords(1) - photonCoords(1));
      yDistanceToFiber = abs(fiberCoords(2) - photonCoords(2));
      distanceToFiber = sqrt(xDistanceToFiber^2 + yDistanceToFiber^2);
      %disp("    Distance to fiber: " + distanceToFiber)
    end

    function [atBoundary, boundary] = checkIfAtBoundary(obj, photonCoords)
      % Check if photon is past the lattice boundaries.
      %
      % If the x-value of the photon is less than the leftmost boundary
      % or greater than the rightmost boundary, or if the y-value of the
      % photon is less than the bottom boundary or greater than the top
      % boundary, the photon is outside the boundaries.
      if photonCoords(1) < obj.boundary_dict('Left')
      disp("Reached LEFT bound at coords: " + coordToString(obj, photonCoords)); disp(' ')
        obj.boundary_impacts_dict('Left') = obj.boundary_impacts_dict('Left') + 1;
        atBoundary = true;
        boundary = 'Left';
      elseif photonCoords(1) > obj.boundary_dict('Right')
      disp("Reached RIGHT bound at coords: " + coordToString(obj, photonCoords)); disp(' ')
        obj.boundary_impacts_dict('Right') = obj.boundary_impacts_dict('Right') + 1;
        atBoundary = true;
        boundary = 'Right';
      elseif photonCoords(2) > obj.boundary_dict('Outer')
      disp("Reached OUTER bound at coords: " + coordToString(obj, photonCoords)); disp(' ')
        obj.boundary_impacts_dict('Outer') = obj.boundary_impacts_dict('Outer') + 1;
        atBoundary = true;
        boundary = 'Outer';
      elseif photonCoords(2) < obj.boundary_dict('Inner')
      disp("Reached INNER bound at coords: " + coordToString(obj, photonCoords)); disp(' ')
        obj.boundary_impacts_dict('Inner') = obj.boundary_impacts_dict('Inner') + 1;
        atBoundary = true;
        boundary = "Inner";
      else
        atBoundary = false;
        boundary = '';
      end

        function count = boundaryCount(obj, boundaryName)
            count = obj.boundary_impacts_dict(boundaryName);
        end
    end

    function coordString = coordToString(obj, coord)
      % Return xy coordinates as a string.
      xCoord = coord(1);
      yCoord = coord(2);
      coordString = string(xCoord) + ", " + string(yCoord);
    end

    function summary = boundarySummary(obj)
      % Summarize how many photons impacted each boundary.
      summary = "Number photons reached INNER bound: " + string(obj.boundary_impacts_dict('Inner'));
      summary = summary + "\nNumber photons reached OUTER bound: " + string(obj.boundary_impacts_dict('Outer'));
      summary = summary + "\nNumber photons reached LEFT bound: " + string(obj.boundary_impacts_dict('Left'));
      summary = summary + "\nNumber photons reached RIGHT bound: " + string(obj.boundary_impacts_dict('Right')) + "\n";
      fprintf(summary)
    end
  end % methods
end
