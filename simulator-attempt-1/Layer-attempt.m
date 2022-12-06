classdef OldLayer
    % Constructs a lattice layer from parameters and runs ray tracing on that lattice.
    %   Define rayTrace() method which runs the rayTraceCoordTowardsInner lattice method,
    %   and which returns an array of the coords of the photons which hit the bottom boundary.
    %
    % Contains a RandomBoundedLattice object.
    properties
      length
      width
      lattice
    end

    methods
        function obj = OldLayer()
          obj.lattice = RandomBoundedLattice(10,10,1);
        end

        function innerBoundCoordArray = rayTrace(obj, initialCoordsArray)
          innerBoundCoordArray = obj.lattice.rayTraceTowardsInner(initialCoordsArray);
          %hold on;
          %plotLayer(obj);
          %plotFiberCircles(obj);
          %plotPhotonPaths(obj, photonPathsCoordArray);
          %setPhotonPathsArray(obj);
        end

        %function obj = setPhotonPathsArray(obj)
        %    obj.photonPathsCoordArray = obj.lattice.photonPathsCoordArray;
        %end

        %function bool = plotAll(obj)
        %    hold on;
            %plotLayer(obj);
            %plotFiberCircles(obj);
            %plotPhotonPaths(obj, obj.photonPathsCoordArray)
            %bool = true;
        %end

        function bool = plotLayer(obj)
              plot(obj.lattice.fiber_data(:,1), obj.lattice.fiber_data(:,2), 'b.', 'MarkerSize', 20);
              lowerXLim = -obj.lattice.lattice_length/2;
              upperXLim = obj.lattice.lattice_length/2;
              lowerYLim = 0;
              upperYLim = obj.lattice.lattice_width;
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

        function bool = plotFiberCircles(obj)
            for row = 1:size(obj.lattice.fiber_data)
                x = obj.lattice.fiber_data(row,1);
                y = obj.lattice.fiber_data(row,2);
                r = obj.lattice.fiber_reflection_radius;
                fiberPlotTheta = linspace(0,2*pi,100);
                fiberPlotXCoords = r * cos(fiberPlotTheta) + x;
                fiberPlotYCoords = r * sin(fiberPlotTheta) + y;
                plot(fiberPlotXCoords, fiberPlotYCoords);
            bool = true;
            end
        end

        function bool = plotPhotonPaths(obj, array)
            plot(array(:,1), array(:,2),'r.','MarkerSize',1);
            bool = true;
        end
    end
end
