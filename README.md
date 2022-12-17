# ffr-photon-simulator-matlab

bubblebath() function from https://www.mathworks.com/matlabcentral/fileexchange/70348-draw-randomly-centered-circles-of-various-sizes

# TODO

1. Put parameter configuration in one place.
2. Assemble bubblebath quadrants according to user input.

# Visuals
Black box  - bubble bath frame and lattice boundary.
Circles    - representation of fibers with center coordinates (dot).
Black dots - centers of the fibers
Red dots   - paths of ray traced photons

# `ffr_simulator.m`
The method `rayTraceSequentialLayers()` ray traces photons through one layer, and makes
the transmitted photons of that layer the incoming photons for the next layer. It
repeats this process for an array of layers, with the first element in the array
as the first layer. For example, the first layer would be the outer exterior layer of
an FFR, the middle layers would be the interior layers of an FFR-- with some
filtering layers, specifically--, and the last layer would be the inner exterior
layer of an FFR.

Each layer has its own boundaries: the inner, outer, left, and right.

For each layer, `rayTraceSequentialLayers()` displays the number of photons which reached:
- the inner boundary
- the outer boundary
- the left boundary
- the right boundary

At the end, it displays the number of photons which reached:
- the inner boundary of inner, exterior layer
- the left boundary of any layer
- the right boundary of any layer

The method `rayTraceSingleLayer()` traces initial photons through a single layer and displays the results.

The method `rayTraceLayerStack()` traces initial photons through a layer stack, which is just a Layer but represents many layers stacked together.

# Classes

## `Layer`

Represents a layer of an N95 filter. Contains
- a fiber lattice
- axis handle to allow plotting

Defines getters to access the 

# Scripts
