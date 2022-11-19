classdef BoundedLattice
	% Make the lattice using bubblebath()
  properties (Constant)
    % Units in meters, seconds unless otherwise specified
    incident_photon_wavelength = 2.5 * 10^(-7); % 254nm

    fiber_diameter             = 4 * 10^(-6); % 4 microns
    fiber_radius               = BoundedLattice.fiber_diameter/2;
    fiber_reflection_radius    = BoundedLattice.fiber_radius + BoundedLattice.incident_photon_wavelength/2;

    fibers_x_separation_basis  = 7.0711 * 10^(-6); % i
    fibers_y_separation_basis  = 7.0711 * 10^(-6); % j
    i = BoundedLattice.fibers_x_separation_basis;
    j = BoundedLattice.fibers_y_separation_basis;
    x_basis_multiplier = 2; % twice the basis is the horizontal distance between fibers
  end
  properties
    general_photon_step

      % Fiber Lattice
    % 10μm diagonal separation means about 14μm horizontal and vertical separation
    % Divide the horizontal and vertical separation in half, and let these be
    % a basis for laying out the lattice.
    fiber_lattice % the lattice array

    % Dimensions in units of fibers
    number_fibers_in_length % integer
    number_fibers_in_width
    x_padding
    y_padding
    lattice_fibers_length % leftmost fiber to rightmost fiber length
    lattice_fibers_width
    lattice_length % add padding
    lattice_width
    % num fibers per quadrant
    lattice_quadrant_density_avg = floor(((BoundedLattice.i^2)/(BoundedLattice.fiber_diameter*pi))/2); % (quadrant area / fiber area) / 2

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
      function obj = BoundedLattice(length, width, generalStepMultiplier)
      obj.general_photon_step = (obj.incident_photon_wavelength / 2) / generalStepMultiplier;
      obj.incident_photon_y_step = -obj.general_photon_step;

      obj.photonXStep = obj.incident_photon_x_step;
      obj.photonYStep = obj.incident_photon_y_step;
      obj.number_fibers_in_length = length;
      obj.number_fibers_in_width = width;
      obj.x_padding = obj.i;
      obj.y_padding = obj.j;
      obj.lattice_fibers_length = (2 * obj.number_fibers_in_length * obj.i); % lattice length w/o padding
      obj.lattice_fibers_width = (obj.number_fibers_in_width * obj.j); % lattice width w/o padding
      obj.lattice_length = obj.lattice_fibers_length + (2 * obj.x_padding);
      obj.lattice_width = obj.lattice_fibers_width + obj.y_padding;

      obj.fiber_lattice = initializeRandomLattice(obj);
      disp(obj.fiber_lattice)
      %obj.fiber_lattice = initializeFiberLattice(obj);
      %disp("Fiber lattice:\n" + obj.fiber_lattice)
      % Boundary dictionary
      % We need to keep track of how many photons impact each boundary. The boundaries
      % are either defined by a constant x-value or constant y-value.
      obj.boundary_names  = {'Outer', 'Inner', 'Left', 'Right'};
      obj.boundary_coords = {obj.lattice_width, 0, -obj.lattice_length/2, obj.lattice_length/2};
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
          reflected = false;
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


    % Fiber latice init methods
    function lattice = initializeRandomLattice(obj)
        lattice = [];
        w = obj.number_fibers_in_width;
        l = obj.number_fibers_in_length;
        for row = -w:w      % -2 -1 0 1 2
            for col = -l:l  % -4 -3 -2 -1 0 1 2 3 4
                qXlow = row * obj.i; % lower x bound of quadrant
                qYlow = col * obj.i; % lower y bound of quadrant
                qXup  = qXlow + obj.i;
                qYup  = qYlow + obj.i;
                xrands = qXlow + (qXup - qXlow).*rand(obj.lattice_quadrant_density_avg, 1); % generate l_q_d_avg rands between x low and high
                yrands = qYlow + (qYup - qYlow).*rand(obj.lattice_quadrant_density_avg, 1);
                for f = 1:size(xrands)
                    fiber = [xrands(f), yrands(f)];
                    disp(fiber)
                    lattice = [lattice; fiber];
                end
            end
        end
    end

    function lattice = initializeFiberLattice(obj)
        lattice = [];
      for fiber = 1:obj.number_fibers_in_width
        if isOdd(obj, fiber)
          oddRow = makeOddFibersRow(obj, fiber*obj.j);
          lattice = [lattice; oddRow];
        else
          evenRow = makeEvenFibersRow(obj, fiber*obj.j);
          lattice = [lattice; evenRow];
        end
      end
    end

    function oddRow = makeOddFibersRow(obj, height)
      leftmostFiber = [ (-obj.lattice_fibers_length / 2), height];
      oddRow  = leftmostFiber;
      for step = 1:(obj.number_fibers_in_length-1)
        nextFiber = [ leftmostFiber(1) + (step * obj.x_basis_multiplier * obj.i), height];
        oddRow = [oddRow ; nextFiber];
      end
    end

    function evenRow = makeEvenFibersRow(obj, height)
      leftmostFiber = [ ((-obj.lattice_fibers_length + 2*obj.i) / 2), height];
      evenRow  = leftmostFiber;
      for step = 1:(obj.number_fibers_in_length-2)
        nextFiber = [leftmostFiber(1) + (step * obj.x_basis_multiplier * obj.i), height];
        evenRow = [evenRow; nextFiber];
      end
    end

    function isodd = isOdd(obj, number)
      % Odd has remainder 1 = true
      % Even has remainder 0 = false
      isodd = rem(number, 2);
    end

    % Photon motion methods
    function [newXStep, newYStep] = calculateNewSteps(obj, reflectionPoint, previousPhotonCoords, reflectedFiberCoords)
     % Find the xstep and ystep of a reflected photon.
      x_i = previousPhotonCoords(1);
      y_i = previousPhotonCoords(2);
      a = reflectionPoint(1);
      b = reflectionPoint(2);
      fibera = reflectedFiberCoords(1);
      fiberb = reflectedFiberCoords(2);

      m = (b -fiberb)/(a - fibera);
      i = b - (m*a);
      n = -1/m;
      j = y_i - (n*x_i);

      C = b + (n*x_i) - (m*a) - y_i;

      t = obj.fibers_x_separation_basis;

      %o = linspace(-3*t,3*t,100);
      %p = m*o + i;

      %plot(o,p,'k.','MarkerSize',5);
      % Plot the radius to the point of reflection.
      %plot([reflectionPoint(1) reflectedFiberCoords(1)], [reflectionPoint(2) reflectedFiberCoords(2)],'k.','MarkerSize',15);
      c= (-m*C)/(m^2 + 1);
      d = (n*c) + j;

      xNew = x_i + 2*(c-x_i);
      yNew = y_i + 2*(d-y_i);
      plot([xNew, yNew ],'k.','MarkerSize',10)

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
      for latticeRow = 1:obj.number_fibers_in_width
        for row = 1:size(obj.fiber_lattice)
            fiberXCoord = obj.fiber_lattice(row,1);
          fiberYCoord = obj.fiber_lattice(row,2);
          fiberCoords = [fiberXCoord fiberYCoord];
          photonDistanceToFiber = calculatePhotonDistanceToFiber(obj, photonCoords, fiberCoords);
          if photonDistanceToFiber < obj.fiber_reflection_radius
            %disp("  Photon distance to fiber: " + photonDistanceToFiber)
            reflected = true;
            reflectedFiberCoords = fiberCoords;
            return;
          end
        end
        reflected = false;
        reflectedFiberCoords = [];
      end
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
