#=
Example of the Gray-Scott model using Julia. A five-point stencil is used to
calculate the Laplacian using array slices.
=#

using Plots

function lap5(f, h2)
    left = f[2:end-1, 1:end-2]
    right = f[2:end-1, 3:end]
    down = f[3:end, 2:end-1]
    up = f[1:end-2, 2:end-1]
    center = f[2:end-1, 2:end-1]
    lap = (left .+ right .+ down .+ up .- 4 .* center) ./ h2
    return lap
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

        lap_u = lap5(U, h)
        lap_v = lap5(V, h)

        u = U[2:end-1, 2:end-1]
        v = V[2:end-1, 2:end-1]

        uvv = u .* v .* v
        u += (Du .* lap_u .- uvv .+ F .* (1 .- u)) .* dt
        v += (Dv .* lap_v .+ uvv .- (F .+ k) .* v) .* dt

        # update main concentration arrays
        U[2:end-1, 2:end-1] = u
        V[2:end-1, 2:end-1] = v

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
