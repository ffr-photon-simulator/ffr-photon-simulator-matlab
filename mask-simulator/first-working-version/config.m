# This is a template config file which will be parsed by ffr_simulator.m to run a simulation.
# The defaults are:
# - 6 layers (outer -> interior (2 filtering) -> inner)
# - 4 quadrants per layer with randomized density (correlated with radii ranges)
# - plotting each layer with initial photons, photon paths, and boundary photons
# - summary of boundary photons

# LAYERS
number of layers
outer layer
inner layer
exterior layers = outer layer + inner layer

filtering layers
interior non-filtering layers
interior layers = filtering + non-filtering

# LAYER CONFIGURATION
layerConfig = struct();
defaultQuadrantConfig = makeQuadrantConfig('preset');
randomQuadrantConfig = makeQuadrantConfig('random');



function quadrants = makeQuadrantConfig(type)
  if type == 'preset'
    config = struct();
    config.densities = [1,0.5,1];
  else
    config = struct();
    config.densities = makeRandomDensities();
  end
end

function densities = makeRandomDensities()
end


# VISUALS
# Plot on?
# Plot each layer?
# Plot only one layer (default last)?

# Fiber circles: on? color?
# Fiber centers: on? color?

# Photon paths: on? color?
# Initial photons: on? color?
# Boundary photons: on? color?


# SUMMARY
# Number photons per boundary?
# Other options.

2. Assemble bubblebath quadrants according to user input.
3. Create system to parse user config files
4. Define user config file
  - ffr-oriented variables (exterior-- outer and inner-- and interior-- filtering and non-filtering-- layers)
  - clear plotting options
  - sane defaults

# Classes

Some under development on the `layer_quadrants` [branch](https://github.com/ffr-photon-simulator/ffr-photon-simulator-matlab/tree/layer_quadrants).

## `QuadrantLayer`

Represents a layer of an N95 filter. Contains
- a QuadrantLattice
- axis handle to allow plotting the layer

Methods
- lattice attribute getters
- plot layer (bounds, fiber centers, fiber circles)
- plot photons (at bounds, ray traced paths)

## `QuadrantLattice`

Represents the fibers in a single layer. Stores Quadrant objects and builds the lattice from the data in the Quadrants.

## `Quadrant`

Represents a quadrant in the fiber lattice. The following parameters used in `bubblebath_noPlot` can be configured:
- size of the quadrant (length and width)
- mininum and maximum radii of the quadrant's fibers
- density of fibers throughout the quadrant

Stores the fiber data and the config struct for `bubblebath_noPlot`.
