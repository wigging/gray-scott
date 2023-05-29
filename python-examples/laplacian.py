"""
Examples of calculating the Laplacian in two dimensions using periodic
boundary conditions.
"""

import numpy as np
import scipy as sp


def lap5_loops(f, h2):
    """
    Five-point stencil to approximate the Laplacian using loops.
    """

    # create ghost nodes at borders
    # 0 0 0 0 0
    # 0 x x x 0
    # 0 x x x 0
    # 0 x x x 0
    # 0 0 0 0 0
    f = np.pad(f, 1)

    # apply periodic boundary conditions
    f[:, 0] = f[:, -2]  # left column
    f[:, -1] = f[:, 1]  # right column
    f[0, :] = f[-2, :]  # top row
    f[-1, :] = f[1, :]  # bottom row

    n = len(f)
    fnew = np.zeros((n, n))

    for i in range(1, n-1):
        for j in range(1, n-1):
            fnew[i, j] = (f[i-1, j] + f[i+1, j] + f[i, j-1] + f[i, j+1] - 4 * f[i, j]) / h2

    return fnew[1:-1, 1:-1]


def lap5_loops2(f, h2):
    """
    Five-point stencil to approximate the Laplacian using loops (version 2).
    """
    f = np.pad(f, 1, mode='wrap')

    n = len(f)
    fnew = np.zeros((n, n))

    for i in range(1, n-1):
        for j in range(1, n-1):
            fnew[i, j] = (f[i-1, j] + f[i+1, j] + f[i, j-1] + f[i, j+1] - 4 * f[i, j]) / h2

    return fnew[1:-1, 1:-1]


def lap5_slices(f, h2):
    """
    Five-point stencil to approximate the Laplacian. The corresponding array
    slices for each component of the stencil are noted.
    """
    f = np.pad(f, 1, mode='wrap')

    left = f[1:-1, :-2]     # shift left for f(x - h, y)
    right = f[1:-1, 2:]     # shift right for f(x + h, y)
    down = f[2:, 1:-1]      # shift down for f(x, y - h)
    up = f[:-2, 1:-1]       # shift up for f(x, y + h)
    center = f[1:-1, 1:-1]  # center for f(x, y)

    fxy = (left + right + down + up - 4 * center) / h2

    return fxy


def lap5_roll(f, h2):
    """
    Five-point stencil to approximate the Laplacian. Each corresponding roll
    function is for each component of the stencil. Notice this gives periodic
    boundary conditions.
    """
    left = np.roll(f, -1, axis=1)   # shift left for f(x - h, y)
    right = np.roll(f, 1, axis=1)   # shift right for f(x + h, y)
    down = np.roll(f, 1, axis=0)    # shift down for f(x, y - h)
    up = np.roll(f, -1, axis=0)     # shift up for f(x, y + h)
    lap = (left + right + down + up - 4 * f) / h2
    return lap


def main():
    """
    Run examples.
    """

    # grid size as n x n
    n = 5

    # create square grid
    grid = np.array(range(n * n)).reshape(n, n)
    # grid = np.random.rand(5, 5)

    # step in space where h is Δx and Δy
    h = 1.0
    h2 = h * h

    print('grid\n', grid)
    print('\nlap5_loops\n', lap5_loops(grid, h2))
    print('\nlap5_loops2\n', lap5_loops2(grid, h2))
    print('\nlap5_slices\n', lap5_slices(grid, h2))
    print('\nlap5_roll\n', lap5_roll(grid, h2))
    print('\nscipy.ndimage.laplace\n', sp.ndimage.laplace(grid, mode='wrap'))


if __name__ == '__main__':
    main()
