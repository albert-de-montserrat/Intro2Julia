using CUDA, LinearAlgebra

x = rand(5) # on CPU
xd = CuArray(x) # move x to device
sin.(xd) 
map(sin, xd)

A = CUDA.rand(5,5) # instantiate matrix directly on GPU
cholesky(A*A'+I)

a = rand(1_000_000)
b = CUDA.rand(1_000_000)

using BenchmarkTools
@btime sin.(a); # 5.5 ms
@btime sin.(b); # 4.6 μs (x100 speed up)