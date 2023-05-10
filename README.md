# Gray-Scott model

This repository contains examples of the Gray-Scott model in various programming languages.

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

Examples of solving the Gray-Scott model are provided for the following programming languages:

- Python
- Swift (in progress)
- Julia (in progress)

**python-examples** - These Python examples use NumPy or SciPy to solve the Gray-Scott model. A five-point stencil is used to approximate the Laplacian. Results are plotted with the Matplotlib package. See the comments in the code files for more information. The examples use model parameters and boundary conditions defined in the Pearson 1993 article.

## Contributing

If you would like to contribute an example to this respository, please create a folder for the example and submit a pull request. Literature such as articles, books, websites, etc. that were used to develop the example should be added to the References section.

## References

References about the Gray-Scott model and numerical techniques for solving it are provided below:

- John E. Pearson. **Complex Patterns in a Simple System**. Science, vol. 261, issue 5118, pp. 189-192, 1993. https://doi.org/10.1126/science.261.5118.189
- Abelson, Adams, Coore, Hanson, Nagpal, Sussman. **Gray Scott Model of Reaction Diffusion**. Accessed 2023. https://groups.csail.mit.edu/mac/projects/amorphous/GrayScott/
- Katharina Käfer and Mirjam Schulz. **Gray-Scott Model of a Reaction-Diffusion System**. Accessed 2023. https://itp.uni-frankfurt.de/~gros/StudentProjects/Projects_2020/projekt_schulz_kaefer/
- Wikipedia. **Five-point stencil**. Accessed 2023. https://en.wikipedia.org/wiki/Five-point_stencil
- Danny Cubic Root. **How to obtain the 9-point Laplacian formula?**. Mathematics Stack Exchange, 2018. https://math.stackexchange.com/q/2916234
- Wikipedia. **Discrete Laplace operator**. Accessed 2023. https://en.wikipedia.org/wiki/Discrete_Laplace_operator
