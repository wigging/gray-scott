#=
Example of the Gray-Scott model using Julia. A five-point stencil is used to
calculate the Laplacian using for-loops.
=#

using Plots

function lap5(f, h2)
    for y = 2:size(f,2) - 1
        for x = 2:size(f,1) - 1
            f[x, y] = (f[x-1,y] + f[x+1,y] + f[x,y-1] + f[x,y+1] - 4 * f[x,y]) / h2
        end
    end
    return f
end

function main()
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
    U = ones(nn, nn)
    V = zeros(nn, nn)

    # initial concentrations at center
    idx = floor(Int, nn / 2)
    low = idx - 10
    high = idx + 10
    U[low:high, low:high] .= 0.5 .+ rand(0:0.01:0.1, 21,21)
    V[low:high, low:high] .= 0.25 .+ rand(0:0.01:0.1, 21,21)

    # solve at each time step
    for i in 1:nt
        print("Running $i/$nt\r")

        UVV = U .* V .* V
        U += (Du .* lap5(U, h) .- UVV .+ F .* (1 .- U)) .* dt
        V += (Dv .* lap_v .+ UVV .- (F .+ k) .* V) .* dt

        # apply periodic boundary conditions
        U[1, :] = U[end-1, :]
        U[:, 1] = U[:, end-1]
        U[end, :] = U[2, :]
        U[:, end] = U[:, 2]

        V[1, :] = V[end-1, :]
        V[:, 1] = V[:, end-1]
        V[end, :] = V[2, :]
        V[:, end] = V[:, 2]
    end

    # plot the final time step
    h = heatmap(U, interpolation="bicubic")
    display(h)
end

main()
