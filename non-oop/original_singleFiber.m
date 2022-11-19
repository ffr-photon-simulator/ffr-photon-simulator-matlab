  % CONSTANTS
% Units in meters, seconds unless otherwise specified

latticeLength               = 2 * 10^(-5);

incidentPhotonWavelength    = 2.5 * 10^(-7); % 254nm
incidentPhotonSpeed         = 3 * 10^8;
incidentPhotonTimeStep      = 5 * 10^(-16); % seconds

fiberRadius                 = 6.5 * 10^(-6);
fiberDiameter               = 1.3 * 10^(-5); % 13 microns
fiberCenter                 = [ 0, 0 ];
fiberReflectionRadius       = 6.575 * 10^(-6);

  % Coordinates
% Center of fiber at (0,0) which is the center of the bounded lattice area.
% Photon travels towards fiber parallel to y-axis.
% Photon starting points on axis parallel to x-axis.

incidentPhotonXStep         = 1.5 * 10^(-7);   % about 21 steps in fiber radius
incidentPhotonInitialXCoord = -3.25 * 10^(-6); % half radius of fiber
incidentPhotonFinalXCoord   = 3.25 * 10^(-6);

incidentPhotonYStep         = 1.5 * 10^(-7); % travelling towards fiber-- doesn't affect initial coords
incidentPhotonInitialYCoord = latticeLength / 2;
incidentPhotonFinalYCoord   = incidentPhotonInitialYCoord; % photon moves parallel to x-axis, for now

incidentPhotonInitialCoords = [ incidentPhotonInitialXCoord, incidentPhotonInitialYCoord ];
incidentPhotonFinalCoords   = [ incidentPhotonFinalXCoord, incidentPhotonFinalYCoord ];

  % ITERATION
% Keep track of the photon through the iteration.
incidentPhotonCoords           = incidentPhotonInitialCoords;
% Initialize matrix to store final coordinates of reflected photons (at boundary).
reflectedPhotonFinalCoordsArray = [ ]; % [ x y ]

% Keep track of the photons
photonTracker = 1;
% x-axis traverse loop
while (incidentPhotonCoords(1) < incidentPhotonFinalCoords(1))
  % Keep track of the photon's distance to the fiber center.
  incidentPhotonDistanceToFiber = sqrt(incidentPhotonCoords(1)^2 + incidentPhotonCoords(2)^2);
  % y-axis traverse loop
  while(incidentPhotonDistanceToFiber > fiberReflectionRadius)
    % Decrement y coord
    incidentPhotonCoords(2) = incidentPhotonCoords(2) - incidentPhotonYStep;
    % Compute distance
    % Center of fiber is (0,0) so Pythagorean Theorem is trivial.
    incidentPhotonDistanceToFiber = sqrt(incidentPhotonCoords(1)^2 + incidentPhotonCoords(2)^2);
  end
  % Reflect off the fiber!
  disp("Photon number " + string(photonTracker) + " reflected at x = " + string(incidentPhotonCoords(1)) + " and y = " + string(incidentPhotonCoords(2)) + ".");
  reflectedPhotonCoords = incidentPhotonCoords;
  % Note: tan(theta) = x-coord / y-coord
  theta = atan(reflectedPhotonCoords(1) / reflectedPhotonCoords(2));
  % Use tan(2 * theta) and the y-coord at reflection to calculate the x-coord boundary
  reflectedPhotonFinalXCoord = reflectedPhotonCoords(2) * tan(2 * theta);
  reflectedPhotonFinalYCoord = latticeLength / 2; % assume infinitely wide lattice boundary
  reflectedPhotonFinalCoordsArray = [ reflectedPhotonFinalCoordsArray; reflectedPhotonFinalXCoord, reflectedPhotonFinalYCoord ];
  % Increment photon's initial x-coord.
  incidentPhotonCoords(1) = incidentPhotonCoords(1) + incidentPhotonXStep;
  % Reset photon's initial y-coord.
  incidentPhotonCoords(2) = incidentPhotonInitialCoords(2);
  % Increase the photon tracker
  photonTracker = photonTracker + 1;
end

  % PLOT
% Photon Distribution
photonPlotXCoords = reflectedPhotonFinalCoordsArray(:,1);
photonPlotYCoords = reflectedPhotonFinalCoordsArray(:,2);

plot(photonPlotXCoords, photonPlotYCoords, 'k.', 'MarkerSize', 20);
hold on
axis equal

% Fiber (semi-circle)
x = fiberCenter(1);
y = fiberCenter(2);
r = fiberRadius;

fiberPlotTheta = linspace(0, pi, 100); % build semi-circle from 100 vectors
fiberPlotXCoords = r * cos(fiberPlotTheta) + x;
fiberPlotYCoords = r * sin(fiberPlotTheta) + y;

plot(fiberPlotXCoords, fiberPlotYCoords)

% Incident photon bounds
xline(incidentPhotonInitialCoords(1), '--');
xline(incidentPhotonFinalCoords(1), '--');

  % Visuals
% Limits
upperYLim = 2 * 10^(-5);
lowerYLim = 0;

upperXLim = 1.25 * 10^(-5);
lowerXLim = -upperXLim;

xlim([lowerXLim upperXLim]);
ylim([lowerYLim upperYLim]);

% Labels
title("Distribution of reflected photons leaving bounded lattice",'FontSize',20);
subtitle("One photon exits the boundary at each dot.",'FontSize',18)

xAxisLabel = "x-axis (meters)";
yAxisLabel = "y-axis (meters)";
xlabel(xAxisLabel,'FontSize',18)
ylabel(yAxisLabel,'FontSize',18)

incidentPhotonLowerBoundLabel = {'\leftarrow Incident photon','     lower x bound'};
incidentPhotonUpperBoundLabel = {'\leftarrow Incident photon','     upper x bound'};

fiberLabel = {'\leftarrow Fiber, r = 6.5\mu'};

text(incidentPhotonInitialCoords(1), 1.1 * incidentPhotonInitialCoords(2), incidentPhotonLowerBoundLabel,'FontSize',14)
text(incidentPhotonFinalCoords(1), 1.1 * incidentPhotonFinalCoords(2), incidentPhotonUpperBoundLabel,'FontSize',14)
text(fiberRadius, 10^(-6), fiberLabel, 'FontSize',14)
