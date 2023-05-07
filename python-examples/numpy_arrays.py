"""
Example of the Gray-Scott model using NumPy arrays. A five-point stencil is
used to calculate the Laplacian. To time this example, comment out the plot
lines at the end of the main() function.
"""

import numpy as np
import matplotlib.pyplot as plt
from time import perf_counter


def laplace(f, h):
    """
    Five-point stencil to approximate the Laplacian. The corresponding array
    slices for each component of the stencil are given below.
    """
    left = f[1:-1, :-2]     # shift left for f(x - h, y)
    right = f[1:-1, 2:]     # shift right for f(x + h, y)
    down = f[2:, 1:-1]      # shift down for f(x, y - h)
    up = f[:-2, 1:-1]       # shift up for f(x, y + h)
    center = f[1:-1, 1:-1]  # center for f(x, y)
    fxy = (left + right + down + up - 4 * center) / h**2
    return fxy


def main():
    """
    Run the Gray-Scott model.
    """
    Du = 0.2    # diffusion coefficient for U
    Dv = 0.1    # diffusion coefficient for V
    F = 0.025   # feed rate
    k = 0.056   # rate constant

    n = 128     # grid size n x n, try a value of 128 or 256
    h = 1       # grid spacing

    nt = 10000  # number of time steps
    dt = 1      # time step

    # initialize arrays with borders as ghost nodes
    # 0 0 0 0 0
    # 0 x x x 0
    # 0 x x x 0
    # 0 x x x 0
    # 0 0 0 0 0
    nn = n + 2
    U = np.ones((nn, nn))
    V = np.zeros((nn, nn))

    # initial concentrations at center
    low = (nn // 2) - 9
    high = (nn // 2) + 10
    U[low:high, low:high] = 0.5 + np.random.uniform(0, 0.1, (19, 19))
    V[low:high, low:high] = 0.25 + np.random.uniform(0, 0.1, (19, 19))

    # solve at each time step
    for n in range(nt):
        print(f'Running {n + 1:,}/{nt:,}', end='\r')

        lap_u = laplace(U, h)
        lap_v = laplace(V, h)

        u = U[1:-1, 1:-1]
        v = V[1:-1, 1:-1]

        uvv = u * v * v
        u += (Du * lap_u - uvv + F * (1 - u)) * dt
        v += (Dv * lap_v + uvv - (F + k) * v) * dt

        # update main concentration arrays
        U[1:-1, 1:-1] = u
        V[1:-1, 1:-1] = v

        # apply periodic boundary conditions
        U[0, :] = U[-2, :]
        U[:, 0] = U[:, -2]
        U[-1, :] = U[1, :]
        U[:, -1] = U[:, 1]

        V[0, :] = V[-2, :]
        V[:, 0] = V[:, -2]
        V[-1, :] = V[1, :]
        V[:, -1] = V[:, 1]

    # plot the final time step
    plt.imshow(U, interpolation='bicubic', cmap=plt.cm.jet)
    plt.show()


if __name__ == '__main__':
    tic = perf_counter()
    main()
    toc = perf_counter()
    print(f'\nElapsed time {toc - tic:.2f} s')
