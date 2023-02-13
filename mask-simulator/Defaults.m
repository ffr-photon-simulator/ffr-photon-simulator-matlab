classdef Defaults
  % A data class that provides default configuration values.
  properties (Constant)
    %%% INITIAL PHOTONS
    % Multipliers
    % Change the x-separation between each initial photon:
    %  >1 decreases the number of photons
    %  <1 increases the number of photons
    separationMultiplier = 100;
    % Change the length of the initial photons' y step:
    %  >1 increases the y step
    %  <1 decreases the y step
    yStepMultiplier = 1;

    % Steps
    initialXStep = 0;
    % Define two initial y steps, one for ray tracing from the outer layer to
    % the inner layer of the FFR, the other for the opposite direction. This
    % is the only change necessary to ray trace in the opposite direction.
    %outerToInnerYStep = -(Photon.WAVELENGTH/2)*yStepMultiplier;
    %innerToOuterYStep = -outerToInnerYStep;
    % The x-separation between each initial photon.
    %separation = abs(outerToInnerYStep)*separationMultiplier;

    %%% FFR Structure
    % Lattice
    F_MIN_SEPARATION = 2*10^(-6);

    LATTICE_I = 10*10^(-6); % convenient x-axis basis for lattice length
    LATTICE_J = 10*10^(-6); % convenient y-axis basis for lattice width
    % FFR Config
    nLayers = 3;

    % FFR Layers Config
    nQLayers = 1;
    layerType = 'filtering'; % inner, filterting, outer

    % Quadrant layer config
    nQuadrants = 2;
    qlWidth = 4*Defaults.LATTICE_J;
    %qlLength = 8 * LATTICE_I;

    % Quadrant config
    qLength = 8*Defaults.LATTICE_I;
    minRadius = 3*10^(-6);
    maxRadius = 6*10^(-6);
    density = 0.3;

  end

  methods
  end
end
