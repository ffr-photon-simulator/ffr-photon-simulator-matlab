classdef RayTracer < handle
    properties
      currFFRLayer
      prevFFRLayer
      outerLayer
      pctAbsorbedByParticle = 5;
    end

    methods
        function obj = RayTracer(ffr)
          obj.outerLayer = ffr.ffrLayers(end);
          obj.currFFRLayer = obj.outerLayer;
        end

        function movePhoton(obj, photon)
          photon.move(); % returns a new Photon object for now
        end

        function distances = distancesToFiber(obj, photon, fiberCoords)
          xDistances = abs(fiberCoords(:,1) - photon.x);
          yDistances = abs(fiberCoords(:,2) - photon.y);
          distances = sqrt(xDistances.^2 + yDistances.^2);
        end

        function currentQuadrant = findCurrentQuadrant(obj, photon)
          %Debug.msg('Finding current quadrant.', 1);
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
          %j = 1:single(quadrantLayer.nQuadrants);
          rightBounds = [quadrants.rightBound];
          leftBounds = [quadrants.leftBound];

          % Find the common index and get the value, i.e. quadrants([0 1 1] & [1 1 0]) -> quadrants([0 1 0])
          % means the photon is in the middle quadrant.
          currentQuadrant = quadrants(rightBounds >= photon.x & leftBounds < photon.x);

          % Fail with a custom alert.
          %if isempty(currentQuadrant)
            %Debug.alert('Current quadrant not found.', 0);
            %Debug.msg('Photon coords: ' + obj.coordToString([ photon.x photon.y ]), 0);
          %end
        end

        function [hasReflected, reflectedFiberCoords] = checkIfReflected(obj, fiberCoords, reflectionRadii, distances)
          reflectedFiberCoords = fiberCoords(distances(:) <= reflectionRadii(:),1:2);
          hasReflected = ~isempty(reflectedFiberCoords);
        end

        function [hasCrossed, crossedFFRBound] = checkIfAtFFRBound(obj, photon, ffr)
          ffrBounds = ffr.boundaries.ffrBounds;
          hasCrossed = false;
          crossedFFRBound = [];

          % Iterate over FFR bounds
          fields = fieldnames(ffrBounds);
          for i = 1:numel(fields)
            bound = ffrBounds.(fields{i});
            if photon.hasCrossedFFRBound(bound) == true
              %Debug.msgWithItem("Crossed FFR bound:", bound, 1);
              hasCrossed = true;
              crossedFFRBound = bound;
              return;
            end
          end
        end

        function hasCrossed = isAtInteriorBound(obj)
          curr = obj.currFFRLayer;
          prev = obj.prevFFRLayer;
          hasCrossed = curr ~= prev; % [C D] ~= [A B]
        end

        function [newXStep, newYStep] = calculateNewSteps(obj, reflectionPoint, incidentPhotonCoords, reflectedFiberCoords)
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
          %layer = [];
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
            %Debug.msgWithItem("Current ffr layer: ", curr, 1);
            %Debug.msgWithItem("Previous ffr layer: ", prev, 1);
          end
        end

        function resetCurrFFRLayer(obj)
          %Debug.msgWithItem("Resetting curr ffr layer to:", obj.outerLayer, 1);
          obj.currFFRLayer = obj.outerLayer;
          %Debug.msgWithItem("Curr ffr layer:", obj.currFFRLayer, 1);
        end

        function [inAbsorptionRadius, absorbedFiberCoords] = withinAbsorptionRadius(obj, fiberCoords, absorptionRadii, distances)
          absorbedFiberCoords = fiberCoords(distances(:) <= absorptionRadii(:), 1:2);
          inAbsorptionRadius = ~isempty(absorbedFiberCoords);
        end

        function [photonPaths, boundInfo] = rayTrace(obj, ffr, incomingPhotons)
          boundInfo = [];
          % Preallocate a massive photonPaths array.
          % Increase size to 10,000,000.
          photonPaths = zeros(10000000,2);
          % We need to keep track of the position within the photonPaths array
          % so we can overwrite the preallocated nan values. Increment this
          % each time coordinates are added to photonPaths.
          pathsIdx = 1;
          insertIdx = 1;

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
              % Only store the photon coordinates every 1000 moves.
              if rem(pathsIdx, 100) == 0
                photonPaths(insertIdx, :) = previousPhotonCoords;
                insertIdx = insertIdx + 1;
              end
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
                %Debug.msg('Not at FFR bound. Check if at interior bound.', 1);
                % Update the current FFR Layer.
                obj.currFFRLayer = obj.findCurrFFRLayer(ffr, photon);
                % Check for interior bound crossings.
                if obj.isAtInteriorBound()
                  %Debug.msg("At interior bound.", 1);
                  [crossedInteriorBound, direction] = obj.findCrossedBound(photon);
                  crossedInteriorBound.addCrossing(photon, direction);
                else
                  %Debug.msg('Not at interior bound.', 1);
                end
                % Check for reflection off a fiber.
                %Debug.msg('Check if reflected.', 1);
                currentQuadrant = obj.findCurrentQuadrant(photon);

                fiberData = currentQuadrant.getFiberData();

                % First two columns of all rows.
                fiberCoords = fiberData(:,1:2);
                reflectionRadii = fiberData(:,3) + (Defaults.photonWavelength / 2);

                % Calculate the distances.
                distances = obj.distancesToFiber(photon, fiberCoords);

                [hasReflected, reflectedFiberCoords] = obj.checkIfReflected(fiberCoords, reflectionRadii, distances);
                if hasReflected == true
                  % Calculate the new steps and make a new Photon with those steps.
                  reflectionPoint = [photon.x, photon.y];
                  [newXStep, newYStep] = obj.calculateNewSteps(reflectionPoint, previousPhotonCoords, reflectedFiberCoords);
                  photon.setSteps(newXStep, newYStep);
                  %Debug.msg('Photon ' + string(photonNum) + ' reflected at fiber: ' + obj.coordToString(reflectedFiberCoords), 1);
                end
                % Check whether the photon is within the absorption radius of a fiber in the current quadrant.
                [inAbsorptionRadius, absorbedFiberCoords] = obj.withinAbsorptionRadius(currentQuadrant, photon);
                % Photon is inside the absorption radius.
                if inAbsorptionRadius == true
                  % If the photon was not inside an absorption radius, it has entered one,
                  %   so increase the possibleAbsorptionCount by 1.
                  % If the photon was inside, do nothing.
                  if photon.inAbsorptionRadius == false
                    curr = obj.currFFRLayer;
                    curr.incrementAbsorptionCount();
                    photon.inAbsorptionRadius = true;
                    %Debug.msg("Entered fiber absorption radius.", 0);
                    %disp(absorbedFiberCoords)
                  end
                % Photon is outside the absorption radius.
                else
                  % If the photon was previously inside the absorption radius, it has just left, so set its
                  %   inAbsorptionRadius property to false.
                  % If the photon was previously outside, do nothing.
                  if photon.inAbsorptionRadius == true
                    photon.inAbsorptionRadius = false;
                    %Debug.msg("Left fiber absorption radius.", 0);
                  end
                end
              end
            end
          end
        end

        function s = coordToString(obj, coords)
          s = string(coords(1)) + ", " + string(coords(2));
        end

    end
end
