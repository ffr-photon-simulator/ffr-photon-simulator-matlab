classdef Defaults
  % A data class that provides default configuration values.
  properties (Constant)
    %%% UNITS
    micron = 10^(-6);
    %%% INITIAL PHOTONS
    % Multipliers
    % Change the x-separation between each initial photon:
    %  >1 increases the number of photons
    %  <1 decreases the number of photons
    separationMultiplier = 1000;
    % Change the length of the initial photons' y step:
    %  >1 increases the y step
    %  <1 decreases the y step
    yStepMultiplier = 1;
    % Wavelength
    photonWavelength = 2.5 * 10^(-7);
    % Separation
    initialSeparation = Defaults.photonWavelength / 2 * Defaults.separationMultiplier;

    % Steps
    initialXStep = 0;
    % Define two initial y steps, one for ray tracing from the outer layer to
    % the inner layer of the FFR, the other for the opposite direction. This
    % is the only change necessary to ray trace in the opposite direction.
    outerToInnerYStep = -(Defaults.photonWavelength/2)*Defaults.yStepMultiplier;
    %outerToInnerYStep = -1.25 * 10^(-7);
    innerToOuterYStep = -Defaults.outerToInnerYStep;
    % The x-separation between each initial photon.
    %separation = abs(outerToInnerYStep)*separationMultiplier;

    %%% FFR Structure
    % Lattice
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6); % convenient x-axis basis for lattice length
    LATTICE_J = 10*10^(-6); % convenient y-axis basis for lattice width

    % FFR Config
    nLayers = 1;

    % FFR Layers
    nQLayers = 1;
    layerType = 'filtering'; % inner, filterting, outer %%% <--

    % Quadrant layers
    nQuadrants = 8;
    qlWidth = 4*Defaults.LATTICE_J;
    %qlLength = 8 * LATTICE_I;

    % Quadrant config
    qLength = 8*Defaults.LATTICE_I;
    qLengthN95I = 80; %%% <--
    qLengthN95 = Defaults.qLengthN95I * Defaults.micron; %%% <--
    qWidthN95I = Defaults.qLengthN95I; %%% <--
    qWidthN95 = Defaults.qWidthN95I * Defaults.micron; %%% <--
    minRadius = 3*10^(-6);
    maxRadius = 6*10^(-6);
    density = 0.3;

    DEBUG_LEVEL = 0;

    % Plotting
    photonPathStyle = 'r.';
    photonPathWeight = 3;
    % Fibers
    fiberCircleStyle = 'k.';
    fiberCircleWeight = 1;
    fiberCenterStyle = 'k.';
    fiberCenterWeight = 5;
    % Interior bounds
    interiorBoundStyle = 'b--';
    interiorBoundWeight = 1;
    % FFR bounds
    ffrBoundStyle = 'k';
    ffrBoundWeight = 2;
  end

  methods (Static)
    function debugMessage(message, messageLevel)
      % If the debug level is greater than or equal to the message level, then display the message.
      if Defaults.DEBUG_LEVEL >= messageLevel
        fprintf("\nDEBUG: " + message)
      end
    end

    function debugStruct(struct, message, messageLevel)
      % If the debug level is greater than or equal to the message level, then display the struct.
      if Defaults.DEBUG_LEVEL >= messageLevel
        fprintf("\nDEBUG Struct: " + message + "\n")
        disp(struct)
      end
    end

    function debugArray(array, message, messageLevel)
      % If the debug level is greater than or equal to the message level, then display the struct.
      if Defaults.DEBUG_LEVEL >= messageLevel
        fprintf("\nDEBUG Array: " + message + "\n")
        disp(array)
      end
    end

    function s = coordToString(coords)
      % Return a string representation of a coordinate pair.
      s = string(coords(1)) + ", " + string(coords(2));
    end
  end
end
