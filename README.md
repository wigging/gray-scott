# Gray-Scott model

This repository contains examples of implementing the Gray-Scott model in various programming languages.

## Governing equations

The Gray-Scott model represents the following irreversible reactions where $P$ is an inert product:

```math
\begin{align}
    U + 2V &\rightarrow 3V \\
    V &\rightarrow P
\end{align}
```

The resulting reaction-diffusion equations in dimensionless units are shown below where $k$ is the dimensionless rate constant of the second reaction and $F$ is the dimensionless feed rate. The diffusion coefficients are $D_u$ and $D_v$ and $\nabla^2$ represents the Laplacian operator.

```math
\begin{align}
    \frac{\partial U}{\partial t} &= D_u \nabla^2 U - U V^2 + F (1 - U) \\
    \frac{\partial V}{\partial t} &= D_v \nabla^2 V + U V^2 - (F + k) V
\end{align}
```

## Examples

Examples of solving the Gray-Scott model in Python, Swift, and Julia are available in this repository. See the comments in the code for more information about that particular example. The examples use model parameters and boundary conditions defined in the Pearson 1993 article. The Laplacian is calculated using a five-point stencil with periodic boundary conditions.

### Julia

The `center.jl` is an example of assigning values at the center of a matrix. The `stencil.jl` demonstrates a two-dimensional five-point stencil. The Gray-Scott model is solved in `grayscott_loops.jl`, `grayscott_slices.jl`, and `grayscott_views.jl` using loops, array slices, and views.

### Python

The `laplacian.py` contains examples of calculating the Laplacian using a five-point stencil and periodic boundary conditions. The Gray-Scott model is solved in `grayscott_slices.py` and `grayscott_movie.py` saves an animation of the results.

<img src="assets/fig1-python.png" width="49%"/> <img src="assets/fig2-python.png" width="49%"/>

The table below compares the elapsed times for each Laplacian function in `laplacian.py` for a 512x512 array. The results are from a 2019 MacBook Pro running a 2.6 GHz 6-core Intel i7 CPU with 32 GB of RAM.

| Function              | Run 1    | Run 2    | Run 3    |
| --------------------- | -------- | -------- | -------- |
| lap5_loops            | 0.5555 s | 0.5794 s | 0.5660 s |
| lap5_loops2           | 0.5516 s | 0.5396 s | 0.5209 s |
| lap5_slices           | 0.0045 s | 0.0039 s | 0.0034 s |
| lap5_roll             | 0.0064 s | 0.0056 s | 0.0051 s |
| lap5_shift            | 0.0026 s | 0.0025 s | 0.0025 s |
| lap5_convolve         | 0.3192 s | 0.3120 s | 0.3136 s |
| scipy.ndimage.laplace | 0.0737 s | 0.0693 s | 0.0659 s |

### Swift

The Swift examples are available as Xcode projects and a playground in the `swift-examples` folder. The `matrix` project demonstrates a two-dimensional `Matrix` struct that makes matrix calculations easier to work with in Swift. The `laplacian` project calculates the Laplacian of a matrix using a five-point stencil and periodic boundary conditions. The `grayscott` project runs the Gray-Scott model and saves the results to a text file. This text file can be used with NumPy and Matplotlib to plot the results. The `grayscott-jeff` playground uses a `Lattice2d` struct for solving the Gray-Scott model and uses PythonKit to plot the results.

The `GrayScottCharts` project is a macOS app that uses Swift Charts to plot the results as shown in the figure below.

<div align="center">
    <img src="assets/fig3-charts.png" width="60%"/>
</div>

The `GrayScottColormap` project is a macOS app that uses Core Graphics to plot the results as seen below. This uses the viridis colormap.

<div align="center">
    <img src="assets/fig4-colormap.png" width="90%"/>
</div>

The `Gray-Scott Torus` project is a MacOS app using Metal to explore various values of F and k with periodic boundary conditions, displaying the results in live time on either a plane or a torus projection.

<div align="center">
    <img src="assets/fig5-torus.jpg" width="60%"/>
</div>

## Contributing

If you would like to contribute an example to this respository, please create a folder for the example and submit a pull request. Literature such as articles, books, websites, etc. that were used to develop the example should be added to the References section (see below).

## References

References about the Gray-Scott model and numerical techniques for solving it are provided below:

- John E. Pearson. **Complex Patterns in a Simple System**. Science, vol. 261, issue 5118, pp. 189-192, 1993. https://doi.org/10.1126/science.261.5118.189
- Abelson, Adams, Coore, Hanson, Nagpal, Sussman. **Gray Scott Model of Reaction Diffusion**. Accessed 2023. https://groups.csail.mit.edu/mac/projects/amorphous/GrayScott/
- Katharina Käfer and Mirjam Schulz. **Gray-Scott Model of a Reaction-Diffusion System**. Accessed 2023. https://itp.uni-frankfurt.de/~gros/StudentProjects/Projects_2020/projekt_schulz_kaefer/
- Wikipedia. **Five-point stencil**. Accessed 2023. https://en.wikipedia.org/wiki/Five-point_stencil
- Danny Cubic Root. **How to obtain the 9-point Laplacian formula?**. Mathematics Stack Exchange, 2018. https://math.stackexchange.com/q/2916234
- Wikipedia. **Discrete Laplace operator**. Accessed 2023. https://en.wikipedia.org/wiki/Discrete_Laplace_operator
