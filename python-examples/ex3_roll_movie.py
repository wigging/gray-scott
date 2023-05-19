"""
Example of the Gray-Scott model using NumPy roll function. This is the same
example as the numpy_roll.py example but saves an animation of the results to
a movie.mp4 file.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation


def laplace(f, h2):
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

    # initialize arrays
    U = np.ones((n, n))
    V = np.zeros((n, n))

    # initial concentrations at center
    low = (n // 2) - 9
    high = (n // 2) + 10
    U[low:high, low:high] = 0.5 + np.random.uniform(0, 0.1, (19, 19))
    V[low:high, low:high] = 0.25 + np.random.uniform(0, 0.1, (19, 19))

    # setup plot figure and initialize list to store plot images
    fig, ax = plt.subplots()
    ims = []

    # solve at each time step
    for n in range(nt):
        print(f'Running {n + 1:,}/{nt:,}', end='\r')

        UVV = U * V * V
        h2 = h * h
        U += (Du * laplace(U, h2) - UVV + F * (1 - U)) * dt
        V += (Dv * laplace(V, h2) + UVV - V * (F + k)) * dt

        if n % 100 == 0:
            im = ax.imshow(U, interpolation='bicubic', cmap=plt.cm.jet, animated=True)
            ims.append([im])

    # plot animation
    ani = animation.ArtistAnimation(fig, ims, interval=50, blit=True)
    ani.save('movie.mp4')

    # plot the final time step
    _, ax = plt.subplots()
    ax.imshow(U, interpolation='bicubic', cmap=plt.cm.jet)
    plt.show()


if __name__ == '__main__':
    main()
