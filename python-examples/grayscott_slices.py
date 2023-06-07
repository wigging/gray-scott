"""
Example of solving the Gray-Scott model using a five-point stencil and
periodic boundary conditions to calculate the Laplacian. The NumPy slices
approach are used in the Laplacian function. To time this example, comment
out the matplotlib import and the plot code.
"""

import numpy as np
import matplotlib.pyplot as plt
from time import perf_counter


def lap5(f, h2):
    """
    Use a five-point stencil with periodic boundary conditions to approximate
    the Laplacian. The corresponding array slices for each component of the
    stencil are noted.
    """
    f = np.pad(f, 1, mode='wrap')

    left = f[1:-1, :-2]     # shift left for f(x - h, y)
    right = f[1:-1, 2:]     # shift right for f(x + h, y)
    down = f[2:, 1:-1]      # shift down for f(x, y - h)
    up = f[:-2, 1:-1]       # shift up for f(x, y + h)
    center = f[1:-1, 1:-1]  # center for f(x, y)

    fxy = (left + right + down + up - 4 * center) / h2

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
    h2 = h * h

    nt = 10000  # number of time steps
    dt = 1      # time step

    # initialize arrays
    U = np.ones((n, n))
    V = np.zeros((n, n))

    # initial concentrations at center
    low = (n // 2) - 9
    high = (n // 2) + 10
    U[low:high, low:high] = 0.5 + np.random.uniform(0, 0.1, (19, 19))
    V[low:high, low:high] = 0.25 + np.random.uniform(0, 0.1, (19, 19))

    # solve at each time step
    for n in range(nt):
        print(f'Running {n + 1:,}/{nt:,}', end='\r')
        UVV = U * V * V
        U += (Du * lap5(U, h2) - UVV + F * (1 - U)) * dt
        V += (Dv * lap5(V, h2) + UVV - V * (F + k)) * dt

    # plot the final time step and save figure to file
    fig, ax = plt.subplots(tight_layout=True)
    ax.imshow(U, interpolation='bicubic', cmap=plt.cm.jet)
    ax.set_title(f'U species, F={F}, k={k}')
    fig.savefig('../assets/fig1-python.png')
    plt.show()


if __name__ == '__main__':
    tic = perf_counter()
    main()
    toc = perf_counter()
    print(f'\nElapsed time {toc - tic:.2f} s')
