% Run at the beginning of the simulator script to introduce quality of life
% and debugging options.
%
% All debug variables are set to a static value in the Defaults class prior
% to running the simulator to allow for global access.
%
% DEBUG_LEVEL: how many comments to display while running the script.

% Clear the screen
clc

% Ask and set the debug level
level = input("> What debug level do you want 0-3? (None: 0)");
if isempty(level)
  level = 0;
end
%Defaults.DEBUG_LEVEL = level;
