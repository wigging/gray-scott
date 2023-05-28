"""
Example of the Gray-Scott model using SciPy laplace function to calculate the
Laplacian. To time this example, comment out the matplotlib import and
associated plot lines at the end of the main() function.
"""

import numpy as np
import matplotlib.pyplot as plt
import scipy as sp
from time import perf_counter


def main():
    """
    Run the Gray-Scott model.
    """
    Du = 0.2    # diffusion coefficient for U
    Dv = 0.1    # diffusion coefficient for V
    F = 0.025   # feed rate
    k = 0.056   # rate constant

    n = 128     # grid size n x n, try a value of 128 or 256
    # h = 1       # grid spacing

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
        lapU = sp.ndimage.laplace(U, mode='wrap')
        lapV = sp.ndimage.laplace(V, mode='wrap')
        U += (Du * lapU - UVV + F * (1 - U)) * dt
        V += (Dv * lapV + UVV - V * (F + k)) * dt

    # plot the final time step
    plt.imshow(U, interpolation='bicubic', cmap=plt.cm.jet)
    plt.show()


if __name__ == '__main__':
    tic = perf_counter()
    main()
    toc = perf_counter()
    print(f'\nElapsed time {toc - tic:.2f} s')
