"""
Example of implementing a 2D five-point stencil using NumPy arrays.
"""

import numpy as np

# Define grid size n x n
n = 6

# Create grid
grid = np.array(range(n * n)).reshape((n, n))
print('grid\n', grid)

# Shift left for f(x - h, y)
left = grid[1:-1, :-2]
print('f(x - h, y)\n', left)

# Shift right for f(x + h, y)
right = grid[1:-1, 2:]
print('f(x + h, y)\n', right)

# Shift down for f(x, y - h)
down = grid[2:, 1:-1]
print('f(x, y - h)\n', down)

# Shift up for f(x, y + h)
up = grid[:-2, 1:-1]
print('f(x, y + h)\n', up)

# Center for f(x, y)
center = grid[1:-1, 1:-1]
print('f(x, y)\n', center)
