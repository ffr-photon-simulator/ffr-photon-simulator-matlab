  % CONSTANTS
% Units in meters, seconds unless otherwise specified

latticeLength               = 2 * 10^(-5); % CHANGE

incidentPhotonWavelength    = 2.5 * 10^(-7); % 254nm
incidentPhotonSpeed         = 3 * 10^8;
incidentPhotonTimeStep      = 5 * 10^(-16); % seconds

fiberRadius                 = 6.5 * 10^(-6);
fiberDiameter               = 1.3 * 10^(-5); % 13 microns
fiberCenter                 = [ 0, 0 ]; % CHANGE
fiberReflectionRadius       = 6.575 * 10^(-6);

  % Lattice
numberFibersInLength        = 41; % must be odd
numberFibersInWidth         = 4;

% 10μm diagonal separation means about 14μm horizontal and vertical separation
fibersXSeparationBasis      = 7.0711 * 10^(-6); % i
fibersYSeparationBasis      = 7.0711 * 10^(-6); % j

% fiberLattice                = [ ];

% Lattice representation of fiber coordinates
% ------------------------------------------------------------------------------
% | [0i 2j]         [2i 2j]          [4i 2j]          [6i 2j]          [8i 2j] |
% |         [ i j ]         [ 3i j ]         [ 5i j ]         [ 7i j ]         |
% | [0i 0j]         [2i 0]           [4i 0]           [6i 0]           [8i 0]  |
% ------------------------------------------------------------------------------

  % Coordinates
% Center of fiber at (0,0) which is the center of the bounded lattice area.
% Photon travels towards fiber parallel to y-axis.
% Photon starting points on axis parallel to x-axis.

incidentPhotonXShift        = 1.5 * 10^(-7);   % about 21 shifts in standard fiber radius
incidentPhotonXStep         = 0;               % incident photons have no x step, but reflected photons do
incidentPhotonInitialXCoord = -3.25 * 10^(-6); % half radius of fiber % CHANGE
incidentPhotonFinalXCoord   = 3.25 * 10^(-6); % CHANGE

incidentPhotonYStep         = 1.5 * 10^(-7); % travelling towards fiber-- doesn't affect initial coords
incidentPhotonInitialYCoord = latticeLength / 2; % CHANGE
incidentPhotonFinalYCoord   = incidentPhotonInitialYCoord; % photon moves parallel to x-axis, for now

incidentPhotonInitialCoords = [ incidentPhotonInitialXCoord, incidentPhotonInitialYCoord ];
incidentPhotonFinalCoords   = [ incidentPhotonFinalXCoord, incidentPhotonFinalYCoord ];

  % FUNCTIONS
% function outputVariable = functionName(inputVariable)
fiberLattice = initializeFiberLattice(numberFibersInLength, numberFibersInWidth, fibersXSeparationBasis, fibersYSeparationBasis);

function myFiberLattice = initializeFiberLattice(numberFibersInLength, numberFibersInWidth, fibersXSeparationBasis, fibersYSeparationBasis)
  myFiberLattice = [];
  fibersInLengthNegativeBound = -((numberFibersInLength - 1)); % one fiber in the center
  fibersInLengthPositiveBound =  ((numberFibersInLength - 1)); % one fiber in the center
  for fiberNumberInWidth = 0:3 % subtract 1 to account for starting at 0
    rowNumber = fiberNumberInWidth + 1;
    fiberLatticeRow = [];
    for fiberNumberInLength = fibersInLengthNegativeBound:2:fibersInLengthPositiveBound % every other even number
      fiberXCoordinate = fiberNumberInLength * (2 * fibersXSeparationBasis);
      fiberYCoordinate = fiberNumberInWidth  * (fibersYSeparationBasis);
      fiberCoordinates = [ fiberXCoordinate; fiberYCoordinate ];
      fiberLatticeRow = [ fiberLatticeRow fiberCoordinates ];
    end
    myFiberLattice(:,:,rowNumber) = fiberLatticeRow;
  end
end



%% function newPhotonCoords = movePhoton(photonXStep, photonYStep, previousPhotonCoords)
%%   newPhotonCoords = [previousPhotonCoords(1) + photonXStep previousPhotonsCoords(2) + photonYStep]
%% end


%% function photonDistanceToFiber = calculatePhotonDistanceToFiber(photonCoords, fiberCoords)
%%   photonXDistanceToFiber = fiberCoords(1) - photonCoords(1)
%%   photonYDistanceToFiber = fiberCoords(2) - photonCoords(2)
%%   photonDistanceToFiber = sqrt(photonXDistanceToFiber^2 + photonYDistanceToFiber^(2))
%% end

%% function hasPhotonReflected = determineIfPhotonReflected(photonDistanceToFiber, fiberReflectionRadius)
%%   if photonDistanceToFiber > fiberReflectionRadius
%%     return false
%%   end
%%   return true
%% end

  % FIBER MATRIX
% Initialize matrix


  % PHOTON MOTION
% Get initial coordinates

%% hasPhotonImpactedBoundary == false
%% hasPhotonReflected == false
%% photonCoords = incidentPhotonInitialCoords;

%% while (hasPhotonImpactedBoundary == false)
%%   while (hasPhotonReflected == false)
%%     photonCoords = movePhoton(photonXStep, photonYStep, photonCoords)
%%     for fiberCoords = [fiberOneCoords fiberTwoCoords ... fiberNCoords]
%%       photonDistanceToFiber = calculatePhotonDistanceToFiber(fiberCoords, photonCoords)
%%       hasPhotonReflected = determineIfPhotonReflected(photonDistanceToFiber, fiberReflectionRadius)
%%       if hasPhotonReflected == true
%%         disp("Reflected")













































%%   % ITERATION
%% % Keep track of the photon through the iteration.
%% incidentPhotonCoords           = incidentPhotonInitialCoords;
%% % Initialize matrix to store final coordinates of reflected photons (at boundary).
%% reflectedPhotonFinalCoordsArray = [ ]; % [ x y ] % CHANGE to represent boundary impact points

%% % Keep track of the photons
%% photonTracker = 1;
%% % x-axis traverse loop
%% while (incidentPhotonCoords(1) < incidentPhotonFinalCoords(1))
%%   % Keep track of the photon's distance to the fiber center.
%%   incidentPhotonDistanceToFiber = sqrt(incidentPhotonCoords(1)^2 + incidentPhotonCoords(2)^2); % CHANGE
%%   % y-axis traverse loop
%%   while(incidentPhotonDistanceToFiber > fiberReflectionRadius)
%%     % Decrement y coord
%%     incidentPhotonCoords(2) = incidentPhotonCoords(2) - incidentPhotonYStep;
%%     % Compute distance
%%     % Center of fiber is (0,0) so Pythagorean Theorem is trivial.
%%     incidentPhotonDistanceToFiber = sqrt(incidentPhotonCoords(1)^2 + incidentPhotonCoords(2)^2);
%%   end
%%   % Reflect off the fiber!
%%   disp("Photon number " + string(photonTracker) + " reflected at x = " + string(incidentPhotonCoords(1)) + " and y = " + string(incidentPhotonCoords(2)) + ".");
%%   reflectedPhotonCoords = incidentPhotonCoords;
%%   % Note: tan(theta) = x-coord / y-coord
%%   theta = atan(reflectedPhotonCoords(1) / reflectedPhotonCoords(2));
%%   % Use tan(2 * theta) and the y-coord at reflection to calculate the x-coord boundary
%%   reflectedPhotonFinalXCoord = reflectedPhotonCoords(2) * tan(2 * theta);
%%   reflectedPhotonFinalYCoord = latticeLength / 2; % assume infinitely wide lattice boundary
%%   reflectedPhotonFinalCoordsArray = [ reflectedPhotonFinalCoordsArray; reflectedPhotonFinalXCoord, reflectedPhotonFinalYCoord ];
%%   % Increment photon's initial x-coord.
%%   incidentPhotonCoords(1) = incidentPhotonCoords(1) + incidentPhotonXStep;
%%   % Reset photon's initial y-coord.
%%   incidentPhotonCoords(2) = incidentPhotonInitialCoords(2);
%%   % Increase the photon tracker
%%   photonTracker = photonTracker + 1;
%% end

%%   % PLOT
%% % Photon Distribution
%% photonPlotXCoords = reflectedPhotonFinalCoordsArray(:,1);
%% photonPlotYCoords = reflectedPhotonFinalCoordsArray(:,2);

%% plot(photonPlotXCoords, photonPlotYCoords, 'k.', 'MarkerSize', 20);
%% hold on
%% axis equal

%% % Fiber (semi-circle)
%% x = fiberCenter(1);
%% y = fiberCenter(2);
%% r = fiberRadius;

%% fiberPlotTheta = linspace(0, pi, 100); % build semi-circle from 100 vectors
%% fiberPlotXCoords = r * cos(fiberPlotTheta) + x;
%% fiberPlotYCoords = r * sin(fiberPlotTheta) + y;

%% plot(fiberPlotXCoords, fiberPlotYCoords)

%% % Incident photon bounds
%% xline(incidentPhotonInitialCoords(1), '--');
%% xline(incidentPhotonFinalCoords(1), '--');

%%   % Visuals
%% % Limits
%% upperYLim = 2 * 10^(-5);
%% lowerYLim = 0;

%% upperXLim = 1.25 * 10^(-5);
%% lowerXLim = -upperXLim;

%% xlim([lowerXLim upperXLim]);
%% ylim([lowerYLim upperYLim]);

%% % Labels
%% title("Distribution of reflected photons leaving bounded lattice",'FontSize',20);
%% subtitle("One photon exits the boundary at each dot.",'FontSize',18)

%% xAxisLabel = "x-axis (meters)";
%% yAxisLabel = "y-axis (meters)";
%% xlabel(xAxisLabel,'FontSize',18)
%% ylabel(yAxisLabel,'FontSize',18)

%% incidentPhotonLowerBoundLabel = {'\leftarrow Incident photon','     lower x bound'};
%% incidentPhotonUpperBoundLabel = {'\leftarrow Incident photon','     upper x bound'};

%% fiberLabel = {'\leftarrow Fiber, r = 6.5\mu'};

%% text(incidentPhotonInitialCoords(1), 1.1 * incidentPhotonInitialCoords(2), incidentPhotonLowerBoundLabel,'FontSize',14)
%% text(incidentPhotonFinalCoords(1), 1.1 * incidentPhotonFinalCoords(2), incidentPhotonUpperBoundLabel,'FontSize',14)
%% text(fiberRadius, 10^(-6), fiberLabel, 'FontSize',14)
