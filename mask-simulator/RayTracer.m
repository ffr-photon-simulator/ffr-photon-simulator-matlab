classdef RayTracer < handle
    % Performs ray tracing on a given Layer (a fiber lattice).
    % The primary method, rayTrace(layer, incomingPhotons), returns the necessary output.
    %
    % rayTrace(layer, incomingPhotons) returns a Map of each boundary name to an array
    % of the Photon objects which crossed each boundary. rayTrace() iterates through
    % each photon in the incomingPhotons array. Because each Photon stores its coordinates
    % and x-y steps, rayTrace() does not have to keep up with the current coordinates and
    % steps, a major design improvement. It simply calls the Photon's methods to move it
    % and set new x-y steps. After the Photon moves, rayTrace() checks if it has crossed
    % a boundary or if it has reflected off of a fiber. If not, the Photon is moved again.
    % If it's at a boundary, the relevant output information is stored and the iteration
    % proceeds to the next photon. If the Photon has reflected, its new x-y steps are
    % calculated and the loop continues.
    properties
      currFFRLayer
      prevFFRLayer
      outerLayer
    end

    methods
        function obj = RayTracer(ffr)
          % Set the current FFR layer to the outer FFR layer.
          obj.outerLayer = ffr.ffrLayers(end);
          obj.currFFRLayer = obj.outerLayer;
        end

        function movePhoton(obj, photon)
          % Move the photon by the x and y steps it has stored.
          photon.move(); % returns a new Photon object for now
        end

        function distances = distancesToFiber(obj, photon, fiberCoords)
          % Calculate the photon's distance to the center of each fiber using vectorization.
          xDistances = abs(fiberCoords(:,1) - photon.x);
          yDistances = abs(fiberCoords(:,2) - photon.y);
          distances = sqrt(xDistances.^2 + yDistances.^2);
        end

        function currentQuadrant = findCurrentQuadrant(obj, photon)
          % Iterate through every quadrant in the current FFR layer and compare
          % the photon's coordinates to the quadrant's boundaries to determine
          % which quadrant the photon is currently in.
          Debug.msg('Finding current quadrant.', 1);
          currentQuadrant = [];
          quadrantLayers = obj.currFFRLayer.quadrantLayers;

          % Vectorize the iteration through the quadrant layers.
          i = 1:obj.currFFRLayer.nQLayers;
          % Use the photon's y coordinate to narrow down which QuadrantLayer it's in.
          % The quadrantLayers list goes in increasing innerBound height order, so check
          % if photon.y is less than the outerBound (not greater than). Use logical indexing.
          quadrantLayer = quadrantLayers(quadrantLayers(i).outerBound > photon.y);

          % Use logical indexing and vectorization to isolate the quadrant in the list which contains the photon.
          % This means finding the common index between the left and right quadrant bounds which the photon can be in.
          quadrants = quadrantLayer.quadrants;

          % Get the left and right bounds of each quadrant.
          j = 1:single(quadrantLayer.nQuadrants);
          rightBounds = [quadrants(j).rightBound];
          leftBounds = [quadrants(j).leftBound];

          % Find the common index and get the value, i.e. quadrants([0 1 1] & [1 1 0]) -> quadrants([0 1 0])
          % means the photon is in the middle quadrant.
          currentQuadrant = quadrants(rightBounds >= photon.x & leftBounds < photon.x);

          % Fail with a custom alert.
          if isempty(currentQuadrant)
            Debug.alert('Current quadrant not found.', 0);
            Debug.msg('Photon coords: ' + obj.coordToString([ photon.x photon.y ]), 0);
          end
        end

        function [hasReflected, reflectedFiberCoords] = checkIfReflected(obj, photon, quadrant)
          % Use vectorization to calculate the distance of the photon to each fiber
          % in the current quadrant. Then, use logical indexing to find a fiber whose
          % reflection radius is greater than or equal to the respective (vectorized) distance.
          fiberData = quadrant.getFiberData();

          % First two columns of all rows.
          fiberCoords = fiberData(:,1:2);
          % Fiber radius plus half wavelength.
          % TODO: put a getReflRadius(radius) function in the Defaults class.
          reflectionRadii = fiberData(:,3) + (Defaults.photonWavelength / 2);

          % Calculate the distances.
          distances = obj.distancesToFiber(photon, fiberCoords);
          % The reflected fiber coords are the x and y columns of the nth row,
          % where n corresponds to the row of distances whose value is less than
          % the reflection radius of the same nth row.
          reflectedFiberCoords = fiberCoords(distances(:) <= reflectionRadii(:),1:2);
          hasReflected = ~isempty(reflectedFiberCoords);
        end

        function [hasCrossed, crossedFFRBound] = checkIfAtFFRBound(obj, photon, ffr)
          % Check if a photon has crossed an FFR boundary by iterating through the bounds.
          ffrBounds = ffr.boundaries.ffrBounds;
          hasCrossed = false;
          crossedFFRBound = [];

          % Iterate over FFR bounds
          fields = fieldnames(ffrBounds);
          for i = 1:numel(fields)
            bound = ffrBounds.(fields{i});
            if photon.hasCrossedFFRBound(bound) == true
              Debug.msgWithItem("Crossed FFR bound:", bound, 1);
              hasCrossed = true;
              crossedFFRBound = bound;
              return;
            end
          end
        end

        function hasCrossed = isAtInteriorBound(obj, photon, ffr)
          % Check if a photon has crossed an interior boundary. To detect an actual crossing,
          % we need to track some representation of the photon's previous position, because
          % the photon's current position alone cannot tell us whether a crossing occurred.
          %
          % A first attempt involved keeping track of the photon's previous position in a boolean
          % value which is false and is set to true if the photon crosses into the interior bound's
          % "range" (small thickness). However, this yielded problems when a photon's slope was so
          % tiny that it actually moved inside the bound more than once in a row. This was counted as
          % two crossings, when in reality it is just a single crossing.
          %
          % To avoid implementing the logic necessary to fix that bug, the current implementation
          % keeps track of which two bounds the photon was between before it moved. If the photon
          % is between a different pair of bounds after it moves, then it has crossed an interior
          % bound. This new pair of bounds is stored and the process is repeated.
          %
          % Say the photon was between interior bounds A and B (A is closer to the outer FFR bound),
          % and now is between interior bounds C and D (C is closer to the outer FFR bound).
          % Regardless of the direction of travel, this A/B -> C/D crossing necessarily
          % implies that bounds B and C are the same, and that this bound is the one
          % that was crossed.
          %
          % We abstract the bounds which the photon is between into the FFR Layer it
          % is currently in. In the line below, imagine the current FFR layer is
          % bounded by C and D, and the previous FFR layer is bounded by A and B.
          curr = obj.currFFRLayer;
          prev = obj.prevFFRLayer;
          hasCrossed = curr ~= prev; % [C D] ~= [A B]
        end

        function [newXStep, newYStep] = calculateNewSteps(obj, reflectionPoint, incidentPhotonCoords, reflectedFiberCoords)
          % Find the slope of the line of the reflected photon.
          %
          % The incident photon's last point before reflection is (inc_x, inc_y). The reflection point is (refl_x, refl_y).
          % The coordinates of the fiber off which the photon reflected are (fiber_x, fiber_y).
          %
          % Draw a line R colinear with the fiber coords and reflection coords (a radius). The path of the reflected photon is the
          % image (reflection) of the path of the incident photon across line R. Draw a line P normal to R and which passes through
          % the incident coords. The image of the incident coords across R is colinear with P. The distance from the incident coords
          % to the reflected coords is twice the distance from the incident coords to the intersection point of R and P.
          %
          % First, find the intersection point I of R and P. Then, calculate the x and y distances from the incident coords to I.
          % Add double these distance to the incident coords to get the reflected coords.
          
          % disp(">> Calculating new steps.")
          inc_x = incidentPhotonCoords(1);
          inc_y = incidentPhotonCoords(2);
          refl_x = reflectionPoint(1);
          refl_y = reflectionPoint(2);
          fiber_x = reflectedFiberCoords(1);
          fiber_y = reflectedFiberCoords(2);

          % m is the slope of line R
          m = (refl_y - fiber_y)/(refl_x - fiber_x);
          n = -1/m; % slope of line P
          yIntP = inc_y - (n*inc_x); % y-intercept of line P

          % Set R = P and solve for x to get (-x/m) - mx = C, where C is a constant.
          % Solve for x to get the x coord of the intersection point I.
          C = refl_y + (n*inc_x) - (m*refl_x) - inc_y; % the constant
          inter_x = (-m*C)/(m^2 + 1); % intersection point x coord
          inter_y = (n*inter_x) + yIntP;  % calculate y coord with equation of line P

          % To get the reflected coords, add to the incident coords double the
          % difference of the incident coords and the intersection point.
          new_x = inc_x + 2*(inter_x-inc_x);
          new_y = inc_y + 2*(inter_y-inc_y);

          % Subtract the coords of the reflection point to get the x and y steps
          % between the reflection point and the reflected photon.
          newXStep = new_x - refl_x;
          newYStep = new_y - refl_y;
        end

        function layer = findCurrFFRLayer(obj, ffr, photon)
          layer = [];
          ffrLayers = ffr.ffrLayers;
          %Debug.msg("Find curr ffr layer photon y: " + photon.y, 1);
          for i = 1:ffr.nLayers
            if ffrLayers(i).containsPhoton(photon)
              layer = ffrLayers(i);
              %Debug.msg("Curr ffr layer i = " + i, 1);
              return;
            end
          end
        end

        function [bound, direction] = findCrossedBound(obj, photon)
          % The shared bound between the current and previous FFR layers
          % is the bound that has been crossed.
          curr = obj.currFFRLayer;
          prev = obj.prevFFRLayer;
          direction = +1; % inner -> outer (positive y movement)
          % Test case for outer -> inner photon travel direction:
          % so curr is closer to inner and prev is closer to outer.
          if curr.outerBound == prev.innerBound
            bound = curr.outerBound;
            direction = -direction;
          % Test case for inner -> outer photon travel direction:
          % so prev is closer to inner and curr is closer to outer.
          elseif prev.outerBound == curr.innerBound
            bound = prev.outerBound;
          else
            bound = "Unknown crossed bound.";
            Debug.alert("Unknown crossed bound. Photon at y = " + photon.y);
            Debug.msgWithItem("Current ffr layer: ", curr, 1);
            Debug.msgWithItem("Previous ffr layer: ", prev, 1);
          end
        end

        function resetCurrFFRLayer(obj)
          Debug.msgWithItem("Resetting curr ffr layer to:", obj.outerLayer, 1);
          obj.currFFRLayer = obj.outerLayer;
          Debug.msgWithItem("Curr ffr layer:", obj.currFFRLayer, 1);
        end

        function [photonPaths, boundInfo] = rayTrace(obj, ffr, incomingPhotons)
          % Ray traces photons starting from initialCoords through an entire FFR.
          boundInfo = [];
          % Preallocate a massive photonPaths array.
          photonPaths = nan(1000000,2);
          % We need to keep track of the position within the photonPaths array
          % so we can overwrite the preallocated nan values. Increment this
          % each time coordinates are added to photonPaths.
          pathsIdx = 1;


          % Get number of rows in first column.
          nPhotons = size(incomingPhotons, 1);

          % Iterate through each incoming photon.
          for photonNum = 1:nPhotons
            Debug.msg("Incident photon number " + photonNum, 0);
            photon = incomingPhotons(photonNum);
            % Initialize values:
            hasCrossedFFRBound = false;
            obj.resetCurrFFRLayer();
            % Reflect the photon until it reaches a boundary.
            while hasCrossedFFRBound == false
              % Update the previous FFR layer.
              obj.prevFFRLayer = obj.currFFRLayer;
              % We need to track the previous photon's coordinates to determine the reflected path.
              previousPhotonCoords = photon.getCoords(); % [x y]
              photonPaths(pathsIdx,:) = previousPhotonCoords;
              pathsIdx = pathsIdx + 1;
              % Move the photon and check if it has reflected or has crossed a boundary
              obj.movePhoton(photon);
              % We want to record any boundary crossings. The photon can either cross an FFR bound or
              % an interior bound.
              %  - If it crosses an FFR bound, we move to the next photon, and do not check for reflection.
              %  - If it crosses an interior bound, it could also potentially have  reflected off a fiber
              %    lying immediately past that bound.
              [hasCrossedFFRBound, crossedFFRBound] = obj.checkIfAtFFRBound(photon, ffr);
              if hasCrossedFFRBound == true
                % Move to the next incident photon if the current one has left the FFR.
                crossedFFRBound.addCrossing(photon);
                Debug.msg('Photon ' + string(photonNum) + ' reached ffr bound: ' + crossedFFRBound.type, 0);
              else
                Debug.msg('Not at FFR bound. Check if at interior bound.', 1);
                % Update the current FFR Layer.
                obj.currFFRLayer = obj.findCurrFFRLayer(ffr, photon);
                % Check for interior bound crossings.
                if obj.isAtInteriorBound(photon, ffr)
                  Debug.msg("At interior bound.", 1);
                  [crossedInteriorBound, direction] = obj.findCrossedBound(photon);
                  crossedInteriorBound.addCrossing(photon, direction);
                else
                  Debug.msg('Not at interior bound.', 1);
                end
                % Check for reflection off a fiber.
                Debug.msg('Check if reflected.', 1);
                currentQuadrant = obj.findCurrentQuadrant(photon);
                [hasReflected, reflectedFiberCoords] = obj.checkIfReflected(photon, currentQuadrant);
                if hasReflected == true
                  % Calculate the new steps and make a new Photon with those steps.
                  reflectionPoint = [photon.x, photon.y];
                  [newXStep, newYStep] = obj.calculateNewSteps(reflectionPoint, previousPhotonCoords, reflectedFiberCoords);
                  photon.setSteps(newXStep, newYStep);
                  Debug.msg('Photon ' + string(photonNum) + ' reflected at fiber: ' + obj.coordToString(reflectedFiberCoords), 1);
                end
              end
            end
          end
        end

        function s = coordToString(obj, coords)
          % Return a string representation of a coordinate pair.
          s = string(coords(1)) + ", " + string(coords(2));
        end
    end
end
