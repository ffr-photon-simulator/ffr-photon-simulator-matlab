classdef Photon < handle
  properties (Constant) % static
    WAVELENGTH = Defaults.photonWavelength;
  end
  properties
    x
    y
    xStep
    yStep
    id
  end

  methods
    function obj = Photon(x, y, xStep, yStep)
      % The photon must be assigned coordinates and x and y steps. At Layer 1,
      % the x step is usually 0 and the y step is usually +- WAVELENGTH/2.
      obj.x = x;
      obj.y = y;
      obj.xStep = xStep;
      obj.yStep = yStep;
      obj.id = extractBefore(char(java.util.UUID.randomUUID), 9); % 9 char hash
    end

    function crossed = hasCrossedFFRBound(obj, bound)
      if isequal(bound.type, 'left') && obj.x <= bound.bound
        %disp('Crossed FFR bound: left')
        crossed = true;
      elseif isequal(bound.type, 'right') && obj.x >= bound.bound
        %disp('Crossed FFR bound: right')
        crossed = true;
      elseif isequal(bound.type, 'outer') && obj.y >= bound.bound
        %disp('Crossed FFR bound: outer')
        crossed = true;
      elseif isequal(bound.type, 'inner') && obj.y <= bound.bound
        %disp('Crossed FFR bound: inner')
        crossed = true;
      else
        %disp('NOT FFR BOUND')
        crossed = false;
      end
    end

    %function crossed = hasCrossedInteriorBound(obj, bound)
    %  % If the photon is in an Interior bound's range (between its upper and lower bounds),
    %  % then it has crossed into the boundary.
    %  crossed = false;
    %  if obj.y <= bound.upperBound && obj.y >= bound.lowerBound
    %    if obj.insideInteriorBound == false
    %      crossed = true;
    %    end
    %  else
    %    obj.insideInteriorBound == true;
    %  end
    %end

    
    function move(obj)
      obj.x = obj.x + obj.xStep;
      obj.y = obj.y + obj.yStep;
    end

    function obj = moveX(obj)
      obj.x = obj.x + obj.xStep;
    end

    function obj = moveY(obj)
      obj.y = obj.y + obj.yStep;
    end

    function coords = getCoords(obj)
      coords = [obj.x obj.y];
    end

    function setSteps(obj, newXStep, newYStep)
      obj.xStep = newXStep;
      obj.yStep = newYStep;
    end

    function obj = setY(obj, newY)
      obj.y = newY;
    end

    function obj = setSteps(obj, xStep, yStep)
      obj.xStep = xStep;
      obj.yStep = yStep;
    end

    function obj = setXStep(obj, step)
      obj.xStep = step;
    end

    function obj = setYStep(obj, step)
      obj.yStep = step;
    end
  end
end
