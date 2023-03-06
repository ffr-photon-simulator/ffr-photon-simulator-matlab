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
    end

    methods
        function obj = RayTracer()
            % Plain constructor because the methods will handle the actual ray tracing.
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
          % Iterate through every quadrant and compare the photon's coordinates
          % to the quadrant's boundaries to determine which quadrant the photon
          % is currently in.
          %disp("Photon " + photon.id + " coords: " + photon.x + "," + photon.y)
          %disp("")
          currentQuadrant = [];
          ffrLayers = ffr.ffrLayers;
          for i = 1:size(ffrLayers)
            ffrLayer = ffrLayers(i);
            quadrantLayers = ffrLayer.quadrantLayers;
            %disp("Iterating through q layers: ")
            %disp(quadrantLayers)
            for j = size(quadrantLayers)
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
                if photon.x >= quadrant.leftBound && photon.x < quadrant.rightBound
                  if photon.y >= quadrant.innerBound && photon.y < quadrant.outerBound
                    currentQuadrant = quadrant;
                    return;
                  end
                end
              end
            end
          end
          Defaults.debugMessage('ERROR: current quadrant not found.', 0)
          Defaults.debugMessage('Photon coords: ' + obj.coordToString([ photon.x photon.y ]), 0)
          Defaults.debugMessage(ffr.printBounds(), 1)
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

        function [atBoundary, boundary] = checkIfAtBoundary(obj, layer, photon)
          % Check if a photon has passed a boundary, in the order: inner,
          % outer, left, right. We could check both the x and y coords of
          % the photon, but only checking one is accurate enough.
          % disp("> Check if at boundary.")
          atBoundary = true;
          if photon.y <= layer.getInnerBound() % negative bound
            boundary = 'inner';
          elseif photon.y >= layer.getOuterBound() % positive bound
            boundary = 'outer';
          elseif photon.x <= layer.getLeftBound() % negative bound
            boundary = 'left';
          elseif photon.x >= layer.getRightBound() % positive bound
            boundary = 'right';
          else
            boundary = 'BOUNDARY_ERROR';
            atBoundary = false;
          end
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

        function photonsAtBoundsMap = rayTrace(obj, layer, incomingPhotons)
          % Ray traces photons starting from initialCoords through a layer.

          nPhotons = size(incomingPhotons, 1); % get number of rows in first col
          % disp("Number of photons: " + nPhotons)
          % Map keys: 'inner', 'outer', 'left', 'right'
          % Map values are arrays of photons: [transmitted], [reflected back], [reflected left], [reflected right]
          boundNames = {'inner','outer','left','right'};
          boundArrays = {[],[],[],[]};
          photonsAtBoundsMap = containers.Map(boundNames, boundArrays); % will store arrays of photons

          % Iterate through each incoming photon.
          for photonNum = 1:nPhotons
            photon = incomingPhotons(photonNum);
            % Initialize values:
            atBoundary = false;
            movedPhoton = photon;
            % Reflect the photon until it reaches a boundary.
            while atBoundary == false
              previousPhoton = movedPhoton;
              % Plot the photon's paths with:
              %plot(layer.getAxisHandle(), previousPhoton.x, previousPhoton.y, 'r.','MarkerSize',3)
              % Move the photon and check if it has reflected or has crossed a boundary
              movedPhoton = obj.movePhoton(previousPhoton);
              [hasReflected, reflectedFiberCoords] = obj.checkIfReflected(movedPhoton, layer);
              [atBoundary, boundary] = obj.checkIfAtBoundary(layer, movedPhoton);
              if atBoundary == true
                % Update a Map of each boundary -> array of photons which crossed it.
                photonsAtBoundsMap(boundary) = [photonsAtBoundsMap(boundary); movedPhoton];
                disp(">> Photon " + photonNum + " reached boundary: " + boundary)
              elseif hasReflected == true
                % Calculate the new steps and make a new Photon with those steps.
                [newXStep, newYStep] = obj.calculateNewSteps([movedPhoton.x, movedPhoton.y], previousPhoton, reflectedFiberCoords);
                movedPhoton = movedPhoton.setSteps(newXStep, newYStep);
                disp("Photon " + photonNum + " reflected at fiber: " + obj.coordToString(reflectedFiberCoords))
              end
            end
            photonNum = photonNum + 1;
          end
        end

        function s = coordToString(obj, coords)
          % Return a string representation of a coordinate pair.
          s = string(coords(1)) + ", " + string(coords(2));
        end
    end
end
