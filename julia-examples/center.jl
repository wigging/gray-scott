#=
Example of assigning values at center of matrix.
=#

n = 11

u = zeros(n, n)
display(u)

idx = floor(Int, n / 2) + 1
u[idx, idx] = 444
display(u)

low = idx - 2
high = idx + 2

u[low:high, low:high] .= 444
display(u)
