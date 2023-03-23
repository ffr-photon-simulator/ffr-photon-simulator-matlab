classdef RayTracer
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
    end

    methods
        function obj = RayTracer(ffr)
          % Set the current FFR layer to the outer FFR layer.
          obj.currFFRLayer = ffr.ffrLayers(end);
          Defaults.debugMessage("RT constructor curr ffr layer: ", 1);
          %disp(obj.currFFRLayer)
        end

        function movedPhoton = movePhoton(obj, photon)
          % Move the photon by the x and y steps it has stored.
          movedPhoton = photon.move(); % returns a new Photon object for now
        end

        function distance = distanceToFiber(obj, photon, fiberCoords)
          % Calculate the photon's distance to the center of a fiber
          % with the Pythagorean Theorem.
          % disp(">> Get distance to fiber.")
          xDistance = abs(fiberCoords(1) - photon.x);
          yDistance = abs(fiberCoords(2) - photon.y);
          distance = sqrt(xDistance^2 + yDistance^2);
        end

        function currentQuadrant = findCurrentQuadrant(obj, photon, ffr)
          % Iterate through every quadrant in the current FFR layer and compare
          % the photon's coordinates to the quadrant's boundaries to determine
          % which quadrant the photon is currently in.
          currentQuadrant = [];
          ffrLayers = ffr.ffrLayers;
          for i = 1:size(ffrLayers)
            Defaults.debugMessage("ffr layer number " + i, 1);
            ffrLayer = ffrLayers(i);
            quadrantLayers = ffrLayer.quadrantLayers;
            %disp("Iterating through q layers: ")
            %disp(quadrantLayers)
            for j = 1:size(quadrantLayers)
              Defaults.debugMessage("qlayer number " + j, 1);
              %disp("Iterating through q layer")
              %disp(quadrantLayer)
              quadrantLayer = quadrantLayers(j);
              % Check quadrant layer's y-value first before iterating through its quadrants. -- TODO
              quadrants = quadrantLayer.quadrants;
              %disp(quadrants)
              %for quadrant = quadrants
              %disp("Iterating through quadrants")
              for q = 1:size(quadrants)
                quadrant = quadrants(q);
                %disp(quadrant)
                %disp("Quadrant bounds: ")
                %disp(quadrant.leftBound)
                %disp("x: " + quadrant.leftBound + " to " + quadrant.rightBound)
                %disp("y: " + quadrant.innerBound + " to " + quadrant.outerBound)
                Defaults.debugMessage("quadrant inner bound: " + quadrant.innerBound, 1);
                Defaults.debugMessage("quadrant outer bound: " + quadrant.outerBound, 1);
                if photon.x >= quadrant.leftBound && photon.x < quadrant.rightBound
                  if photon.y >= quadrant.innerBound && photon.y < quadrant.outerBound
                    currentQuadrant = quadrant;
                    return;
                  end
                end
              end
            end
          end
        Defaults.debugMessage('Current quadrant not found.', 0)
        Defaults.debugMessage('Photon coords: ' + obj.coordToString([ photon.x photon.y ]), 0)
        end

        function [hasReflected, reflectedFiberCoords] = checkIfReflected(obj, photon, quadrant)
          % Determine which Quadrant the photon is in. For each fiber in that quadrant,
          % calculate the photon's distance to it. If the distance is less than that
          % fiber's reflection radius, the photon has reflected off that fiber.
          % disp("> Check if reflected.")
          fiberData = quadrant.getFiberData();

          for row = 1:size(fiberData)
            fiberCoords = [fiberData(row,1), fiberData(row,2)];
            fiberReflectionRadius = fiberData(row, 3) + (Defaults.photonWavelength / 2); % fiber radius plus half wavelength
            distanceToFiber = obj.distanceToFiber(photon, fiberCoords);
            if distanceToFiber < fiberReflectionRadius
              hasReflected = true;
              reflectedFiberCoords = fiberCoords;
              return;
            else
              hasReflected = false;
              reflectedFiberCoords = [];
            end
          end
        end

        function [hasCrossed, crossedFFRBound] = checkIfAtFFRBound(obj, photon, ffr)
          % Check if a photon has crossed an FFR boundary by iterating through the bounds.
          ffrBounds = ffr.boundaries.ffrBounds; % TODO add this to FFR
          hasCrossed = false;
          crossedFFRBound = [];

          % Iterate over FFR bounds
          fields = fieldnames(ffrBounds);
          for i = 1:numel(fields)
            bound = ffrBounds.(fields{i});
            %disp(b)
            if photon.hasCrossedFFRBound(bound) == true
              hasCrossed = true;
              crossedFFRBound = bound;
              return; % photon won't have crossed an interior bound, so we can skip it
            end
          end
        end

        function [hasCrossed, crossedInteriorBound] = checkIfAtInteriorBound(obj, photon, ffr)
          % Check if a photon has crossed an interior boundary by iterating through the bounds.
          % To detect an actual crossing, we need to track some representation of the photon's
          % previous position, because the photon's current position alone cannot tell us
          % whether a crossing occurred.
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
          hasCrossed = false;
          crossedInteriorBound = [];
          %if photon.insideInteriorBound == true
            %return;
          %end
          %interiorBounds = ffr.boundaries.interiorBounds;

          % The photon was between bounds A and B (A is closer to the outer FFR bound),
          % and now is between bounds C and D (C is closer to the outer FFR bound).
          % Regardless of the direction of travel, this A/B -> C/D crossing necessarily
          % implies that bounds B and C are the same, and that this bound is the one
          % that was crossed.
          %
          % We abstract the bounds which the photon is between into the FFR Layer it
          % is currently in. The current FFR layer is bounded by C and D, and the previous
          % FFR layer is bounded by A and B.

          % Find the FFR Layer with the current photon
          if ~ isequal(obj.currFFRLayer, obj.prevFFRLayer) % [C D] != [A B]
            hasCrossed = true;
            % If we actually ran the simulation from both directions, the crossed interior
            % bound would be currFFRLayer.innerBound for the inner -> outer direction.
            crossedInteriorBound = obj.currFFRLayer.outerBound; % C
          end

          % Iterate over interior bounds
          %for i = 1:size(interiorBounds)
            %bound = interiorBounds(i);
            %if photon.hasCrossedInteriorBound(bound) == true
              %crossedInteriorBound = bound;
              %hasCrossed = true;
              %return;
            %end
          %end
        end

        function [newXStep, newYStep] = calculateNewSteps(obj, reflectionPoint, incidentPhoton, reflectedFiberCoords)
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
          inc_x = incidentPhoton.x;
          inc_y = incidentPhoton.y;
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
          Defaults.debugMessage("photon y: " + photon.y, 1);
          for i = 1:size(ffrLayers)
            Defaults.debugMessage("\n", 1);
            Defaults.debugMessage("i = " + i, 1);
            if ffrLayers(i).containsPhoton(photon)
              layer = ffrLayers(i);
              Defaults.debugMessage("Curr ffr layer i = " + i, 1);
              return;
            end
          end
        end

        function bound = findCrossedInteriorBound(obj)
          % The shared bound between the current and previous FFR layers
          % is the bound that has been crossed.
          curr = obj.currFFRLayer;
          prev = obj.prevFFRLayer;
          % Test case for outer -> inner photon travel direction:
          % so curr is closer to inner and prev is closer to outer.
          if isequal(curr, prev)
            bound = curr.outerBound
          % Test case for inner -> outer photon travel direction:
          % so prev is closer to inner and curr is closer to outer.
          elseif isequal(prev.outerBound, curr.innerBound)
            bound = prev.outerBound
          end
        end

        function [photonPaths, boundInfo] = rayTrace(obj, ffr, incomingPhotons)
          % Ray traces photons starting from initialCoords through an entire FFR.

          boundInfo = [];
          photonPaths = [];

          % Get number of rows in first column.
          nPhotons = size(incomingPhotons, 1);

          % Iterate through each incoming photon.
          for photonNum = 1:nPhotons
            Defaults.debugMessage('New incident photon.', 1);
            photon = incomingPhotons(photonNum);
            % Initialize values:
            hasCrossedFFRBound = false;
            movedPhoton = photon;
            % Reflect the photon until it reaches a boundary.
            while hasCrossedFFRBound == false
              previousPhoton = movedPhoton;
              photonPaths = [photonPaths; previousPhoton.x previousPhoton.y];
              % Move the photon and check if it has reflected or has crossed a boundary
              movedPhoton = obj.movePhoton(previousPhoton);
              % We want to record any boundary crossings. The photon can either cross an FFR bound or
              % an interior bound.
              %  - If it crosses an FFR bound, we move to the next photon, and do not check for reflection.
              %  - If it crosses an interior bound, it could also potentially have  reflected off a fiber
              %    lying immediately past that bound.
              [hasCrossedFFRBound, crossedFFRBound] = obj.checkIfAtFFRBound(movedPhoton, ffr);
              if hasCrossedFFRBound == true
                % Move to the next incident photon if the current one has left the FFR.
                crossedFFRBound.addCrossing(movedPhoton);
                Defaults.debugMessage('Photon ' + string(photonNum) + ' reached ffr bound: ' + crossedFFRBound.type, 0);
              else
                Defaults.debugMessage('Not at FFR bound. Check if at interior bound.', 1);
                % Update the previous and current FFR Layer
                obj.prevFFRLayer = obj.currFFRLayer;
                Defaults.debugMessage("prev ffr layer: ", 1);
                obj.currFFRLayer = obj.findCurrFFRLayer(ffr, photon);
                if ~ isequal(obj.currFFRLayer, obj.prevFFRLayer)
                  Defaults.debugMessage('At interior bound.', 1);
                  crossedInteriorBound = obj.findCrossedInteriorBound();
                  crossedInteriorBound.addCrossing(movedPhoton);
                else
                  Defaults.debugMessage('Not at interior bound.', 1);
                end
                Defaults.debugMessage('Check if reflected.', 1);
                Defaults.debugMessage('Finding current quadrant.', 1);
                currentQuadrant = obj.findCurrentQuadrant(movedPhoton, ffr);
                [hasReflected, reflectedFiberCoords] = obj.checkIfReflected(movedPhoton, currentQuadrant);
                if hasReflected == true
                  % Calculate the new steps and make a new Photon with those steps.
                  [newXStep, newYStep] = obj.calculateNewSteps([movedPhoton.x, movedPhoton.y], previousPhoton, reflectedFiberCoords);
                  movedPhoton = movedPhoton.setSteps(newXStep, newYStep);
                  Defaults.debugMessage('Photon ' + string(photonNum) + ' reflected at fiber: ' + obj.coordToString(reflectedFiberCoords), 1)
                end
              end
             %elseif hasReflected == true
             %  % Calculate the new steps and make a new Photon with those steps.
             %  [newXStep, newYStep] = obj.calculateNewSteps([movedPhoton.x, movedPhoton.y], previousPhoton, reflectedFiberCoords);
             %  movedPhoton = movedPhoton.setSteps(newXStep, newYStep);
             %  disp("Photon " + photonNum + " reflected at fiber: " + obj.coordToString(reflectedFiberCoords))
             %end
            end
          end
        end

        function s = coordToString(obj, coords)
          % Return a string representation of a coordinate pair.
          s = string(coords(1)) + ", " + string(coords(2));
        end
    end
end
