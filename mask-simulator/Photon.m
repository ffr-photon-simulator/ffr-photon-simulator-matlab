classdef Photon
  properties (Constant) % static
    WAVELENGTH = 2.5*10^(-7);
  end
  properties
    x
    y
    xStep
    yStep
  end

  methods
    function obj = Photon(x, y, xStep, yStep)
      % The photon must be assigned coordinates and
      % x and y steps. At Layer 1, the x step is usually 0 and
      % the y step is usually +- WAVELENGTH/2.
      obj.x = x;
      obj.y = y;
      obj.xStep = xStep;
      obj.yStep = yStep;
      %disp("New photon made with: ")
      %disp(obj.x)
      %disp(obj.y)
    end

    function obj = move(obj)
      obj.x = obj.x + obj.xStep;
      obj.y = obj.y + obj.yStep;
    end

    function obj = moveX(obj)
      %disp("Photon obj:")
      %disp(obj)
      %obj.xStep
      %disp("Old x: " + obj.x)
      obj.x = obj.x + obj.xStep;
      %disp("New x: " + obj.x)
    end

    function obj = moveY(obj)
      %disp("Old y: " + obj.y)
      %disp(obj.yStep)
      obj.y = obj.y + obj.yStep;
      %disp("New y: " + obj.y)
    end

    function coords = getCoords(obj)
      coords = [obj.x obj.y];
    end

    function obj = setX(obj, x)
      obj.x = x;
    end

    function obj = setY(obj, y)
      obj.y = y;
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
