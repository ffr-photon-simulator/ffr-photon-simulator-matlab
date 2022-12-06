classdef RayTracer
    % Performs ray tracing on a given Layer (fiber lattice).
    % The primary method, rayTrace(layer, incomingPhotons), returns the necessary output.

    properties
    end

    methods
        function obj = RayTracer()
            % Plain constructor because rayTrace() will handle the actual
            % ray tracing.
        end

        function movedPhoton = movePhoton(obj, photon)
          %disp("> Move photon.")
          % Move the photon by both its xStep and yStep.
          %photon.moveX();
          %photon.moveY();
          %disp(photon)
          movedPhoton = photon.move();
        end

        function distance = distanceToFiber(obj, photon, fiberCoords)
          %disp(">> Get distance to fiber.")
          % Calculate the photon's distance to the center of a fiber
          % with the Pythagorean Theorem.
          xDistance = abs(fiberCoords(1) - photon.x);
          yDistance = abs(fiberCoords(2) - photon.y);
          distance = sqrt(xDistance^2 + yDistance^2);
        end

        function [hasReflected, reflectedFiberCoords] = checkIfReflected(obj, photon, layer)
          %disp("> Check if reflected.")
          % For each fiber in the lattice, calculate the photon's distance to it. If the distance
          % is less than that fiber's reflection radius, the photon has reflected.
          fibers = layer.getFiberData();
          for row = 1:size(fibers)
            fiberCoords = [fibers(row,1), fibers(row,2)];
            fiberReflectionRadius = fibers(row, 3) + (Photon.WAVELENGTH / 2);
            distanceToFiber = obj.distanceToFiber(photon, fiberCoords);
            %disp(distanceToFiber)
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
          %disp("> Check if at boundary.")
          % Check if a photon has passed a boundary, in the order: inner,
          % outer, left, right. We could check both the x and y coords of
          % the photon, but only checking one is accurate enough.
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
            boundary = '';
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
          %
          %disp(">> Calculating new steps.")
          inc_x = incidentPhoton.x;
          inc_y = incidentPhoton.y;
          refl_x = reflectionPoint(1);
          refl_y = reflectionPoint(2);
          fiber_x = reflectedFiberCoords(1);
          fiber_y = reflectedFiberCoords(2);

          % m is the slope of R
          m = (refl_y - fiber_y)/(refl_x - fiber_x);
          n = -1/m; % slope of P
          yIntP = inc_y - (n*inc_x); % y-intercept of P

          % Set R = P and get (-x/m) - mx = C. Solve for x to get the x coord of the intersection point I.
          C = refl_y + (n*inc_x) - (m*refl_x) - inc_y; % constant
          inter_x = (-m*C)/(m^2 + 1); % intersection x coord
          inter_y = (n*inter_x) + yIntP;  % calculate y coord

          % Add to the incident coords double the difference of the incident coords and the intersection point
          % to get the reflected coords.
          new_x = inc_x + 2*(inter_x-inc_x); % new photon x coord
          new_y = inc_y + 2*(inter_y-inc_y); % new photon y coord

          % Subtract the coords of the reflection point to get the x and y steps between the reflection point
          % and the reflected photon.
          newXStep = new_x - refl_x;
          newYStep = new_y - refl_y;
        end

        function photonsAtBoundsMap = rayTrace(obj, layer, incomingPhotons)
          % Ray traces photons starting from initialCoords through a layer
          nPhotons = size(incomingPhotons, 1); % get number of rows in first col
          %disp("Number of photons: " + nPhotons)
          % Map keys: 'inner', 'outer', 'left', 'right'
          % Map values are arrays of photons: [transmitted], [reflected back], [reflected left], [reflected right]
          boundNames = {'inner','outer','left','right'};
          boundArrays = {[],[],[],[]};
          photonsAtBoundsMap = containers.Map(boundNames, boundArrays); % will store arrays of photons
          photonCount = 1;

          hold on;
          % Iterate through each incoming photon.
          for i = 1:nPhotons
            %disp("Ray trace method at photon " + photonCount)
            photon = incomingPhotons(i);
            %disp(photon)
            atBoundary = false;
            movedPhoton = photon; % starting value
            % Reflect the photon until it reaches a boundary.
            while atBoundary == false
              %prevcoords = previousPhoton.getCoords();
              %disp(obj.coordToString(prevcoords))
              previousPhoton = movedPhoton;
              plot(previousPhoton.x, previousPhoton.y, 'r.','MarkerSize',3)
              movedPhoton = obj.movePhoton(previousPhoton);
              %newcoords = movedPhoton.getCoords();
              %disp(obj.coordToString(newcoords))
              %disp(movedPhoton.getCoords())
              [hasReflected, reflectedFiberCoords] = obj.checkIfReflected(movedPhoton, layer);
              [atBoundary, boundary] = obj.checkIfAtBoundary(layer, movedPhoton);
              if atBoundary == true
                disp("Reached boundary: " + boundary)
                photonsAtBoundsMap(boundary) = [photonsAtBoundsMap(boundary); movedPhoton];
                % Do not reset the xy steps because each incoming photon already has them.
              elseif hasReflected == true
                disp("Photon " + photonCount + " reflected at fiber: " + obj.coordToString(reflectedFiberCoords))
                [newXStep, newYStep] = obj.calculateNewSteps([movedPhoton.x, movedPhoton.y], previousPhoton, reflectedFiberCoords);
                movedPhoton = movedPhoton.setSteps(newXStep, newYStep);
                %movedPhoton.setXStep(newXStep);
                %movedPhoton.setYStep(newYStep);
              end
            end
            photonCount = photonCount + 1;
          end
        end

        function s = coordToString(obj, coords)
          s = string(coords(1)) + ", " + string(coords(2));
        end
    end
end
