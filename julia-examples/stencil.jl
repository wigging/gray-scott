#=
Example of implementing a 2D five-point stencil.
=#

# Define grid size n x n
n = 6

# Create grid and use border as ghost nodes
# 0 0 0 0 0
# 0 x x x 0
# 0 x x x 0
# 0 x x x 0
# 0 0 0 0 0
grid = reshape(1:n*n, n, n)
display(grid)

# Shift left for f(x - h, y)
left = grid[2:end-1, 1:end-2]
println("\nleft f(x - h, y)")
display(left)

# Shift right for f(x + h, y)
right = grid[2:end-1, 3:end]
println("\nright f(x + h, y)")
display(right)

# Shift down for f(x, y - h)
down = grid[3:end, 2:end-1]
println("\ndown f(x, y - h)")
display(down)

# Shift up for f(x, y + h)
up = grid[1:end-2, 2:end-1]
println("\nup f(x, y + h)")
display(up)

# Center for f(x, y)
center = grid[2:end-1, 2:end-1]
println("\ncenter f(x, y)")
display(center)

# Calculate the Laplacian using five-point stencil
function lap5(f, h2)
    left = f[2:end-1, 1:end-2]
    right = f[2:end-1, 3:end]
    down = f[3:end, 2:end-1]
    up = f[1:end-2, 2:end-1]
    center = f[2:end-1, 2:end-1]
    lap = (left + right + down + up - 4 * center) / h2
    return lap
end

# Laplacian of the grid
h = 0.25
h2 = h^2
laplacian = lap5(grid, h2)
println("\nlaplacian")
display(laplacian)
