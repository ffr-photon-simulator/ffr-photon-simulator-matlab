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
    inAbsorptionRadius = false;
  end

  methods
    function obj = Photon(x, y, xStep, yStep)
      obj.x = x;
      obj.y = y;
      obj.xStep = xStep;
      obj.yStep = yStep;
      obj.id = extractBefore(char(java.util.UUID.randomUUID), 9); % 9 char hash
    end

    function crossed = hasCrossedFFRBound(obj, bound)
      if isequal(bound.type, 'left') && obj.x <= bound.bound
        crossed = true;
      elseif isequal(bound.type, 'right') && obj.x >= bound.bound
        crossed = true;
      elseif isequal(bound.type, 'outer') && obj.y >= bound.bound
        crossed = true;
      elseif isequal(bound.type, 'inner') && obj.y <= bound.bound
        %Debug.msg("Crossed inner FFR bound with photon.y = " + obj.y, 1);
        crossed = true;
      else
        crossed = false;
      end
    end

    function move(obj)
      obj.x = obj.x + obj.xStep;
      obj.y = obj.y + obj.yStep;
    end

    function coords = getCoords(obj)
      coords = [obj.x obj.y];
    end

    function setSteps(obj, newXStep, newYStep)
      obj.xStep = newXStep;
      obj.yStep = newYStep;
    end

  end
end
