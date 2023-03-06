%% Simulates an FFR.
% Generate the config
config

% Make the FFR
ffr = FFR(ffrConfig);


% Generate the incoming photons
xStart = -Defaults.nQuadrants * Defaults.qLength / 2;
xEnd = -xStart;
outerBound = ffr.ffrBounds.outerBound;
initialPhotons = makeInitialPhotons(xStart, xEnd, Defaults.initialSeparation, outerBound, Defaults.initialXStep, Defaults.outerToInnerYStep);



% FUNCTIONS
function photons = makeInitialPhotons(xStart, xEnd, separation, outerBoundary, initialXStep, outerToInnerYStep)
  % The photons' x-axis range is from xStart to xEnd. Their y coordinate is
  % equal to the value of the outer boundary. The initial photons are
  % separated by the value of the "separation" variable.
  nPhotons = (xEnd-xStart) / separation;
  disp("Num photons: " + nPhotons)
  photons = [];
  bound = outerBoundary.bound;
  for m = 1:nPhotons
    nextPhoton = Photon(xStart + m*separation, bound, initialXStep, outerToInnerYStep);
    %nextPhoton = Photon(xStart + m*separation, Defaults.nQLayers * Defaults.qlWidth, initialXStep, outerToInnerYStep);
    photons = [photons; nextPhoton];
  end
end
