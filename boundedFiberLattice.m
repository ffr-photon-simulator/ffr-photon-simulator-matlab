function []=boundedFiberLattice(nfil, nfiw, latticeOffset, incShift, stepFactor)
% CONSTANTS
% The Standard Parameters include:
%  - general photon step: (incident_photon_wavelength / 2)
%  - lattice shift: 0
%  - incident photon shift: general photon step
% Units in meters, seconds unless otherwise specified
incident_photon_wavelength = 2.5 * 10^(-7); % 254nm
general_photon_step        = (incident_photon_wavelength / 2) / stepFactor;
%incident_photon_speed      = 3 * 10^8;
%incident_photon_time_step  = general_photon_step / incident_photon_speed; % seconds

fiber_diameter             = 4 * 10^(-6); % 4 microns
fiber_radius               = fiber_diameter/2;
fiber_reflection_radius    = fiber_radius + incident_photon_wavelength/2;

  % Fiber Lattice
% 10μm diagonal separation means about 14μm horizontal and vertical separation
% Divide the horizontal and vertical separation in half, and let these be
% a basis for laying out the lattice.
fibers_x_separation_basis  = 7.0711 * 10^(-6); % i
fibers_y_separation_basis  = 7.0711 * 10^(-6); % j
i = fibers_x_separation_basis;
j = fibers_y_separation_basis;
x_basis_multiplier = 2; % twice the basis is the horizontal distance between fibers
%y_basis_multiplier = 2; % twice the basis is the vertical distance between fibers

% Representation of fiber coordinates in the lattice
% --------------------------------------------------------------------------  <-- outer boundary at y=4j
% | [0i 3j]        [2i 3j]         [4i 3j]         [6i 3j]         [8i 3j] |
% |         [i 2j]         [3i 2j]         [5i 2j]         [7i 2j]         |
% | [0i  j]        [2i  j]         [4i  j]         [6i  j]         [8i  j] |
% --------------------------------------------------------------------------  <-- inner boundary at y=0
% ^ leftmost boundary will be at x=-9i                                     ^  rightmost boundary at x=9i

% Dimensions in units of fibers
%number_fibers_in_length = 16; % Must be odd.
%number_fibers_in_width  = 4;
number_fibers_in_length = nfil; % Must be odd.
number_fibers_in_width  = nfiw;
x_padding = i;
y_padding = j;
lattice_fibers_length = (2 * number_fibers_in_length * i); % lattice length w/o padding
lattice_fibers_width = (number_fibers_in_width * j); % lattice width w/o padding
lattice_length = lattice_fibers_length + (2 * x_padding);
lattice_width = lattice_fibers_width + y_padding;

% Boundary dictionary
% We need to keep track of how many photons impact each boundary. The boundaries
% are either defined by a constant x-value or constant y-value.
boundary_names  = {'Outer', 'Inner', 'Left', 'Right'};
boundary_coords = {lattice_width, 0, -lattice_length/2, lattice_length/2};
boundary_dict   = containers.Map(boundary_names, boundary_coords);
boundary_impacts = {0,0,0,0}; % count of number of impacts on each boundary
boundary_impact_dict = containers.Map(boundary_names, boundary_impacts);

  % Coordinates
% Photon initially travels towards fiber parallel to y-axis.
% Photon starting points are on the axis parallel to x-axis.
incident_photon_x_shift         = (incident_photon_wavelength / 2) / incShift;
incident_photon_x_step          = 0; % reflected photons have an x step, so initialize it here
incident_photon_initial_x_coord = -i;
incident_photon_final_x_coord   = i;

incident_photon_y_step          = -general_photon_step;
incident_photon_initial_y_coord = lattice_width;
incident_photon_final_y_coord   = incident_photon_initial_y_coord; % photon moves parallel to x-axis, for now

incident_photon_initial_coords  = [ incident_photon_initial_x_coord, incident_photon_initial_y_coord ];
incident_photon_final_coords    = [ incident_photon_final_x_coord, incident_photon_final_y_coord ];


  % FIBER LATTICE
% Initialize matrix
testShift = latticeOffset;
fiber_lattice = initializeFiberLattice(number_fibers_in_length, number_fibers_in_width, lattice_fibers_length, i, j, x_basis_multiplier, testShift);

  % PHOTON MOTION
leaveBoundsCoordsArray = []; % [ x, y, photon_number ]
photonPathCoordsArray = [];

% Start at incident photon coordiantes
incidentPhotonCoords = incident_photon_initial_coords;
previousPhotonCoords = incident_photon_initial_coords;
% Set x and y steps
photonXStep = incident_photon_x_step;
photonYStep = incident_photon_y_step;
% Set the first photon's coordinates
photonCoords = incidentPhotonCoords;

% Main Process
atBoundary = false;
reflected = false;
photonTracker = 1;
while (incidentPhotonCoords(1) < incident_photon_final_coords(1))
    reflected = false;
    atBoundary = false;
    previousPhotonCoords = photonCoords;
    photonPathCoordsArray = [photonPathCoordsArray; photonCoords];
    photonCoords = movePhoton(photonXStep, photonYStep, photonCoords);
    [reflected, reflectedFiberCoords] = checkIfReflected(photonCoords,fiber_lattice,fiber_reflection_radius);
    atBoundary = checkIfAtBoundary(photonCoords, boundary_dict, boundary_impact_dict);
    if atBoundary == true
        leaveBoundsCoordsArray = [leaveBoundsCoordsArray; photonCoords, photonTracker];
        photonXStep = incident_photon_x_step;
        photonYStep = incident_photon_y_step;
        incidentPhotonCoords(1) = incidentPhotonCoords(1) + incident_photon_x_shift;
        photonCoords = incidentPhotonCoords;
        photonTracker = photonTracker + 1;
    elseif reflected == true
        disp("Photon " + photonTracker + " reflected off of fiber at: " + coordToString(reflectedFiberCoords))
        disp(" - Photon coords: " + coordToString(photonCoords))
        [newXStep, newYStep] = calculateNewSteps(photonCoords, previousPhotonCoords, reflectedFiberCoords, general_photon_step);
        photonXStep = newXStep;
        photonYStep = newYStep;
        %disp("    Photon x step: " + photonXStep)
        %disp("    Photon y step: " + photonYStep)
    end
end
% Print a summary of the boundaries.
fprintf(boundarySummary(boundary_impact_dict))
disp("")

  % PLOTS
% Lattice fiber points
plotLattice(fiber_lattice,lattice_width,lattice_length);
% Lattice fiber circles
for row = 1:size(fiber_lattice)
  fiberXCoord = fiber_lattice(row,1);
  fiberYCoord = fiber_lattice(row,2);
  fiberCoords = [fiberXCoord fiberYCoord];
  plotFiberCircle(fiberCoords, fiber_reflection_radius)
end
% Photons (in blue)
plotBoundPhotonPoints(leaveBoundsCoordsArray);
% Photon paths
plotPhotonPaths(photonPathCoordsArray);
% Incident photon bounds
xline(incident_photon_initial_coords(1), '--');
xline(incident_photon_final_coords(1), '--');

% Save figure
saveFigure(nfil, nfiw, latticeOffset, incShift, stepFactor);

  % FUNCTIONS
% Syntax: function outputVariable = functionName(inputVariable)
% Lattice
function lattice = initializeFiberLattice(number_fibers_in_length, number_fibers_in_width, lattice_fibers_length, i, j, x_basis_multiplier, testShift)
  lattice = [];
  for fiber = 1:number_fibers_in_width
    if isOdd(fiber)
      oddRow = makeOddFibersRow(number_fibers_in_length, lattice_fibers_length, i, j*fiber, x_basis_multiplier, testShift);
      lattice = [lattice; oddRow];
    else
      evenRow = makeEvenFibersRow(number_fibers_in_length, lattice_fibers_length, i, j*fiber, x_basis_multiplier, testShift);
      lattice = [lattice; evenRow];
    end
  end
end
function oddRow = makeOddFibersRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier, testShift)
  leftmostFiber = [ (-lattice_fibers_length / 2) + testShift, j];
  oddRow  = leftmostFiber;
  for step = 1:(number_fibers_in_length-1)
    nextFiber = [ leftmostFiber(1) + (step * x_basis_multiplier * i), j];
    oddRow = [oddRow ; nextFiber];
  end
end
function evenRow = makeEvenFibersRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier, testShift)
  leftmostFiber = [ ((-lattice_fibers_length + 2*i) / 2) + testShift, j];
  evenRow  = leftmostFiber;
  for step = 1:(number_fibers_in_length-2)
    nextFiber = [leftmostFiber(1) + (step * x_basis_multiplier * i), j];
    evenRow = [evenRow; nextFiber];
  end
end
function isodd = isOdd(number)
  % Odd has remainder 1 = true
  % Even has remainder 0 = false
  isodd = rem(number, 2);
end

% Photon Motion
function [newXStep, newYStep] = calculateNewSteps(photonCoords, previousPhotonCoords, reflectedFiberCoords, general_photon_step)
  % Find the xstep and ystep of a reflected photon.
  %
  % The path of the reflected photon is the image of the path of the
  % incident photon mirrored (reflected) across the line co-linear
  % with the center of the fiber and the point of reflection on the
  % surface of the fiber.
  %
  % The slope of the reflected photon's path is the ratio of the
  % ystep and xstep. We need to scale the {x,y}steps so that the
  % hypotenuse of the triangle defined by these steps equals
  % the general_photon_step (one half-wavelength). We can use
  % trigonometry to scale the {x,y}steps.
  %
  % To get this slope, take the reciprocal of the slope of the
  % path of the incident photon. We can calculate the incident
  % photon's slope using the photon's previous coordinates
  % and the reflection coordinates.
  %
  % RETURNS
  % newXStep: the step in the x-direction of the reflected photon.
  % newYStep: the step in the y-direction of the reflected photon.
  reflectionPoint = photonCoords;
  incidentSlope = calculateSlope(reflectionPoint, previousPhotonCoords);
  % Case 1 and 2: incident slope is infinite
  if (incidentSlope == Inf) || (incidentSlope == -Inf)
    % Case 1
    % Incident path is colinear with fiber center.
    if (photonCoords(2) == reflectedFiberCoords(2))
      newXStep = 0;
      if (photonCoords(2) > previousPhotonCoords(2))
        % Photon was travelling up, reflects down
        reflectedPathDirection = -1;
      elseif (photonCoords(2) < previousPhotonCoords(2))
        % Photon was travelling down, reflects up
        reflectedPathDirection = 1;
      end
      newYStep = general_photon_step * reflectedPathDirection;
    % Case 2
    % Incident path is not colinear with fiber center.
    else
      % Incident path is parallel to y-axis, but has hit some other section of
      % the fiber. The arctan of the angle between the incident path and the radius
      % equals the ratio of the x-distance to the y-distance between the
      % reflection point and fiber center.
      phi = calculateReflectionPointAngleToXAxis(reflectionPoint, reflectedFiberCoords);
      % sin(2*phi)/cos(2*phi) gives the slope of the reflected photon's path
      newXStep = general_photon_step * sin(phi);
      newYStep = general_photon_step * cos(phi);
    end
  % Case 3: incident slope is not infinite
  else
    phi = calculateReflectionPointAngleToXAxis(reflectionPoint, reflectedFiberCoords);
    yIntercept = calculateYIntercept(phi, reflectedFiberCoords);
    reflectedPoint = reflectPoint(previousPhotonCoords, phi, yIntercept);
    newXStep = reflectedPoint(1) - reflectedFiberCoords(1);
    newYStep = reflectedPoint(2) - reflectedFiberCoords(2);
  end
end

function angle = calculateReflectionPointAngleToXAxis(reflectionPoint, reflectedFiberCoords)
  xDistance = reflectionPoint(1) - reflectedFiberCoords(1);
  yDistance = reflectionPoint(2) - reflectedFiberCoords(2);
  angle = atan(xDistance/yDistance);
end

function yInt = calculateYIntercept(slopeAngle, point)
  % b = y - mx
  slope = tan(slopeAngle);
  yInt = point(2) - (slope * point(1));
end

function reflectedPoint = reflectPoint(point, angle, yIntercept)
  % Use a reflection matrix.
  reflectionMatrix = [cos(2*angle) sin(2*angle); sin(2*angle) -cos(2*angle) ];
  pointMinusY = point - yIntercept;
  reflectedPointMinusY = pointMinusY * reflectionMatrix;
  reflectedPoint = reflectedPointMinusY + yIntercept;
end

% Unused
%   if (incidentSlope == Inf) || (incidentSlope == -Inf)
%     % It's possible that the photon's path is colinear with the center of
%     % the fiber, but unlikely.
%     if previousPhotonCoords(1) == reflectionPoint(1)
%       % Incident path is colinear with the center of the fiber, so the
%       % reflection angle is 0.
%       newXStep = 0;
%       newYStep = general_photon_step;
%     else
%       % Incident path is parallel to y-axis, but has hit some other section of
%       % the fiber. arctan of the angle between the incident path and the radius
%       % equals the ratio of the x-distance to the y-distance between the
%       % reflection point and fiber center.
%       xDistance = reflectionPoint(1) - reflectedFiberCoords(1);
%       yDistance = reflectionPoint(2) - reflectedFiberCoords(2);
%       phi = atan(xDistance/yDistance);
%       % sin(2*phi)/cos(2*phi) gives the slope of the reflected photon's path
%       newXStep = general_photon_step * sin(phi);
%       newYStep = general_photon_step * cos(phi);
%     end
%   else
%     reflectedSlope = 1/incidentSlope;
%     % The reflected path makes angle theta with the x-axis.
%     theta = atan(reflectedSlope);
%     newXStep = general_photon_step * cos(theta);
%     newYStep = general_photon_step * sin(theta);
%   end
% end

function slope = calculateSlope(previousPoint, nextPoint)
  % Calculate the slope of the line connecting a previous point
  % and a next point.
  slope = (nextPoint(2) - previousPoint(2)) / (nextPoint(1) - previousPoint(1));
end

function [reflected, reflectedFiberCoords] = checkIfReflected(photonCoords,fiber_lattice,fiber_reflection_radius)
  % Check if a photon has reflected off a fiber.
  %
  % Iterate through the fiber lattice and calculate the distance from the photon to
  % each fiber. If that distance is less than the fibers's reflection radius, then
  % the photon has reflected at the current photonCoords.
  %
  % RETURNS
  % reflected: tells the loop whether the photon has reflected; either true or false.
  % reflectedFiberCoords: the coordinates of the fiber off which the photon reflected.
  %for latticeRow = 1:number_fibers_in_width
    for row = 1:size(fiber_lattice)
        fiberXCoord = fiber_lattice(row,1);
        fiberYCoord = fiber_lattice(row,2);
        fiberCoords = [fiberXCoord fiberYCoord];
        photonDistanceToFiber = calculatePhotonDistanceToFiber(photonCoords, fiberCoords);
        if photonDistanceToFiber < fiber_reflection_radius
          disp("  Photon distance to fiber: " + photonDistanceToFiber)
          reflected = true;
          reflectedFiberCoords = fiberCoords;
        return;
        end
    end
  reflected = false;
  reflectedFiberCoords = [];
end

function newCoords = movePhoton(xStep, yStep, previousCoords)
  % Move the photon in the x and y directions.
  newCoords = [previousCoords(1) + xStep,  previousCoords(2) + yStep];
end

function distanceToFiber = calculatePhotonDistanceToFiber(photonCoords, fiberCoords)
  % abs() is technically unnecessary since we square it in the pythagorean theorem,
  % but keep it for clarity
  xDistanceToFiber = abs(fiberCoords(1) - photonCoords(1));
  yDistanceToFiber = abs(fiberCoords(2) - photonCoords(2));
  distanceToFiber = sqrt(xDistanceToFiber^2 + yDistanceToFiber^2);
  %disp("    Distance to fiber: " + distanceToFiber)
end

function atBoundary = checkIfAtBoundary(photonCoords, boundary_dict, boundary_impacts_dict)
  % Check if photon is past the lattice boundaries.
  %
  % If the x-value of the photon is less than the leftmost boundary
  % or greater than the rightmost boundary, or if the y-value of the
  % photon is less than the bottom boundary or greater than the top
  % boundary, the photon is outside the boundaries.
  if photonCoords(1) < boundary_dict('Left')
    disp("Reached LEFT bound at coords: " + coordToString(photonCoords)); disp(' ')
    boundary_impacts_dict('Left') = boundary_impacts_dict('Left') + 1;
    atBoundary = true;
  elseif photonCoords(1) > boundary_dict('Right')
    disp("Reached RIGHT bound at coords: " + coordToString(photonCoords)); disp(' ')
        boundary_impacts_dict('Right') = boundary_impacts_dict('Right') + 1;
    atBoundary = true;
  elseif photonCoords(2) > boundary_dict('Outer')
    disp("Reached OUTER bound at coords: " + coordToString(photonCoords)); disp(' ')
        boundary_impacts_dict('Outer') = boundary_impacts_dict('Outer') + 1;
    atBoundary = true;
  elseif photonCoords(2) < boundary_dict('Inner')
    disp("Reached INNER bound at coords: " + coordToString(photonCoords)); disp(' ')
        boundary_impacts_dict('Inner') = boundary_impacts_dict('Inner') + 1;
    atBoundary = true;
  else
    atBoundary = false;
  end
end
% Plotting
% Every function must return a value, so have plotting functions return a dummy boolean.
function bool = saveFigure(nfil, nfiw, latticeOffset, incShift, stepFactor)
  frame = getframe(gcf);
  figureName = "lattice_" + nfil + "x" + nfiw + "_offset" + (latticeOffset * 10^(6)) + "u.png"
  disp("Figure saved as: " + figureName)
  imwrite(frame.cdata, figureName)
end
function bool = plotPhotonPaths(photonPathsArray)
  plot(photonPathsArray(:,1), photonPathsArray(:,2), 'k.','MarkerSize',1);
end 
function bool = plotLattice(fiber_lattice,lattice_width,lattice_length)
  clf; % clear current plot
  plot(fiber_lattice(:,1), fiber_lattice(:,2), 'k.', 'MarkerSize', 20);
  hold on;
  % Fibers
  lowerXLim = -lattice_length/2;
  upperXLim = lattice_length/2;
  lowerYLim = 0;
  upperYLim = lattice_width;
  xlim([lowerXLim, upperXLim]);
  ylim([lowerYLim, upperYLim]);
  % Boundaries
  xline(lowerXLim, '--');
  xline(upperXLim, '--');
  yline(lowerYLim, '--');
  yline(upperYLim, '--');
  axis equal;
  bool = true;
end
function bool = plotBoundPhotonPoints(leaveBoundsCoordsArray)
  plot(leaveBoundsCoordsArray(:,1), leaveBoundsCoordsArray(:,2), 'b.', 'MarkerSize', 20);
  bool = true;
end
function bool = plotFiberCircle(fiberCoords, fiber_reflection_radius)
  x = fiberCoords(1);
  y = fiberCoords(2);
  r = fiber_reflection_radius;
  fiberPlotTheta = linspace(0,2*pi,100); % build semi-circle from 100 vectors
  fiberPlotXCoords = r * cos(fiberPlotTheta) + x;
  fiberPlotYCoords = r * sin(fiberPlotTheta) + y;
  plot(fiberPlotXCoords, fiberPlotYCoords)
end

% Quality of life
function alert = alert(message)
  % Return a formatted alert string.
  alert = fprintf("\n>>> " + message);
end

function coordString = coordToString(coord)
  % Return xy coordinates as a string.
  xCoord = coord(1);
  yCoord = coord(2);
  coordString = string(xCoord) + ", " + string(yCoord);
end

function summary = boundarySummary(boundary_impacts_dict)

  % Summarize how many photons impacted each boundary.
  summary = "Number photons reached INNER bound: " + string(boundary_impacts_dict('Inner'));
  summary = summary + "\nNumber photons reached OUTER bound: " + string(boundary_impacts_dict('Outer'));
  summary = summary + "\nNumber photons reached LEFT bound: " + string(boundary_impacts_dict('Left'));
  summary = summary + "\nNumber photons reached RIGHT bound: " + string(boundary_impacts_dict('Right')) + "\n";
end

end
