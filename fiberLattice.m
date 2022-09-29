% Constants
fibers_x_separation_basis  = 7.0711 * 10^(-6); % i, defined as half the horizontal distance between fibers
fibers_y_separation_basis  = 7.0711 * 10^(-6); % j, defined as half the vertical distance between fibers
x_basis_multiplier = 2; % twice the basis is the horizontal distance between fibers
y_basis_multiplier = 2; % twice the basis is the vertical distance between fibers

i = fibers_x_separation_basis;
j = fibers_y_separation_basis;

number_fibers_in_length = 41;
number_fibers_in_width = 4;
x_padding = i;
y_padding = j;
lattice_fibers_length = (2 * number_fibers_in_length * i);
lattice_fibers_width = (2 * number_fibers_in_width * j);
lattice_length = lattice_fibers_length + (2 * x_padding);
lattice_width = lattice_fibers_width + (2 * y_padding);

% Script
fiber_lattice = initializeFiberLattice(number_fibers_in_length, number_fibers_in_width, lattice_fibers_length, i, j, x_basis_multiplier);
b = plotLattice(fiber_lattice, lattice_width, lattice_length);

% Functions
function lattice = initializeFiberLattice(number_fibers_in_length, number_fibers_in_width, lattice_fibers_length, i, j, x_basis_multiplier)
  lattice = [];
  for fiber = 1:number_fibers_in_width
    if isOdd(fiber)
      oddRow = makeOddFibersRow(number_fibers_in_length, lattice_fibers_length, i, j*fiber, x_basis_multiplier);
      lattice = [lattice; oddRow];
    else
      disp("even row: " + fiber)
      evenRow = makeEvenFibersRow(number_fibers_in_length, lattice_fibers_length, i, j*fiber, x_basis_multiplier);
      disp(evenRow)
      lattice = [lattice; evenRow];
    end
  end
end

function oddRow = makeOddFibersRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier)
  disp("making odd row at j=" + j)
  leftmostFiber = [ -lattice_fibers_length / 2, j];
  oddRow  = [leftmostFiber];
  for step = 1:(number_fibers_in_length-1);
    nextFiber = [ leftmostFiber(1) + (step * x_basis_multiplier * i), j];
    oddRow = [oddRow ; nextFiber];
  end
end

function evenRow = makeEvenFibersRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier)
  disp("making even row at j=" + j)
  leftmostFiber = [ (-lattice_fibers_length + 2*i) / 2, j];
  evenRow  = [leftmostFiber];
  for step = 1:(number_fibers_in_length-2);
    nextFiber = [leftmostFiber(1) + (step * x_basis_multiplier * i), j];
    evenRow = [evenRow; nextFiber];
  end
end

function isodd = isOdd(number)
  % Odd has remainder 1 = true
  % Even has remainder 0 = false
  isodd = rem(number, 2);
end

function firstRow = makeFirstRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier)
  leftmostFiber = [ -lattice_fibers_length / 2, j];
  firstRow  = [leftmostFiber];
  for step = 1:(number_fibers_in_length-1);
    nextFiber = [ leftmostFiber(1) + (step * x_basis_multiplier * i), j];
    firstRow = [firstRow ; nextFiber];
  end
end

function secondRow = makeSecondRow(number_fibers_in_length, lattice_fibers_length, i, j, x_basis_multiplier)
  leftmostFiber = [ (-lattice_fibers_length + 2*i) / 2, 2*j];
  secondRow  = [leftmostFiber];
  for step = 1:(number_fibers_in_length-2);
    nextFiber = [leftmostFiber(1) + (step * x_basis_multiplier * i), 2*j];
    secondRow = [secondRow; nextFiber];
  end
end

function bool = plotLattice(fiber_lattice,lattice_width,lattice_length)
  plot(fiber_lattice(:,1), fiber_lattice(:,2), 'k.', 'MarkerSize', 20);
  hold on;
  % Fibers
  lowerXLim = -lattice_length/2;
  upperXLim = lattice_length/2;
  lowerYLim = 0;
  upperYLim = lattice_width/2;
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
