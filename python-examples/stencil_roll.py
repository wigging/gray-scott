"""
Example of implementing a 2D five-point stencil using NumPy roll function.
"""

import numpy as np

# Define grid size n x n
n = 6

# Create grid
grid = np.array(range(n * n)).reshape((n, n))
print('grid\n', grid)

# Shift left for f(x - h, y)
left = np.roll(grid, -1, axis=1)
print('f(x - h, y)\n', left)

# Shift right for f(x + h, y)
right = np.roll(grid, 1, axis=1)
print('f(x + h, y)\n', right)

# Shift down for f(x, y - h)
down = np.roll(grid, 1, axis=0)
print('f(x, y - h)\n', down)

# Shift up for f(x, y + h)
up = np.roll(grid, -1, axis=0)
print('f(x, y + h)\n', up)


# Calculate the Laplacian using five-point stencil
def lap5(f, h2):
    f_left = np.roll(f, -1, axis=1)
    f_right = np.roll(f, 1, axis=1)
    f_down = np.roll(f, 1, axis=0)
    f_up = np.roll(f, -1, axis=0)
    lap = (f_left + f_right + f_down + f_up - 4 * f) / h2
    return lap


# Laplacian of the grid
h = grid[0, 1] - grid[0, 0]
h2 = h * h
laplacian = lap5(grid, h2)
print('laplacian\n', laplacian)
