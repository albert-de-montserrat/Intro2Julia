import Base:getindex

abstract type Mesh end
abstract type QuadraticMesh <:Mesh end
abstract type LinearMesh <:Mesh end

struct Grid{T, M, N} 
    c0::NTuple{3, M} # origin corner
    c1::NTuple{3, M} # opposite corner
    nels::NTuple{3, N} # number of elements
    nnods::NTuple{3, N} # number of nodes
    nxny::Int64
    x::Vector{M} # nodal ranges
    y::Vector{M} # nodal ranges
    z::Vector{M} # nodal ranges
end

struct LazyGrid{M, N} 
    c0::NTuple{3, M} # origin corner
    c1::NTuple{3, M} # opposite corner
    Δ::NTuple{3, M} # directional steps
    nels::NTuple{3, N} # number of elements
    nnods::NTuple{3, N} # number of nodes
    nxny::Int64
end

struct Point{T}
    x::T
    y::T
    z::T
end

Π(n::NTuple{N, T}) where {N, T} = foldl(*, n)

function grid(c0, c1, nnods, T::Type{LinearMesh})
    nels = nnods.-1
    
    x = collect(LinRange(c0[1], c1[1], nnods[1]))
    y = collect(LinRange(c0[2], c1[2], nnods[2]))
    z = collect(LinRange(c0[3], c1[3], nnods[3]))
    
    Grid{T, eltype(c0), eltype(nels)}(
        c0,
        c1,
        nels,
        nnods,
        nnods[1]*nnods[2],
        x,
        y,
        z,
    )

end

function lazy_grid(c0, c1, nnods)
    nels = nnods.-1
    
    Δx = (c1[1] - c0[1])/(nnods[1]-1)
    Δy = (c1[2] - c0[2])/(nnods[2]-1)
    Δz = (c1[3] - c0[3])/(nnods[3]-1)
    
    LazyGrid(
        c0,
        c1,
        (Δx, Δy, Δz),
        nels,
        nnods,
        nnods[1]*nnods[2],
    )

end

function getindex(gr::Grid, I::Int, J::Int, K::Int)
    @assert I <= gr.nnods[1]
    @assert J <= gr.nnods[2]
    @assert K <= gr.nnods[3]
    Point(gr.x[I], gr.y[J], gr.z[K])
end

function getindex(gr::LazyGrid, I::Int, J::Int, K::Int)
    @assert I <= gr.nnods[1]
    @assert J <= gr.nnods[2]
    @assert K <= gr.nnods[3]
    Point(
        gr.c0[1] + (I-1)*gr.Δ[1],
        gr.c0[2] + (J-1)*gr.Δ[2],
        gr.c0[3] + (K-1)*gr.Δ[3],
    )
end

function getindex(gr::Grid, I::Int)
    @assert I <= Π(gr.nnods)
    i,j,k = CartesianIndex(gr, I)
    Point(gr.x[i], gr.y[j], gr.z[k])
end

function getindex(gr::LazyGrid, I::Int)
    @assert I <= Π(gr.nnods)
    i,j,k = CartesianIndex(gr, I)
    gr[i,j,k]
end

getindex(gr::Grid, ::NTuple{N, T}) where {N, T} = [gr[i] for i in 1:N]   
getindex(gr::LazyGrid, ::NTuple{N, T}) where {N, T} = [gr[i] for i in 1:N]

function CartesianIndex(gr::Grid, I::Int)
    nx = gr.nnods[1]
    i = mod(I-1, nx)+1
    k = div(I, gr.nxny, RoundUp)
    j = div(I-gr.nxny*(k-1), nx, RoundUp)
    (i, j, k)
end

function CartesianIndex(gr::LazyGrid, I::Int)
    nx = gr.nnods[1]
    i = mod(I-1, nx)+1
    k = div(I, gr.nxny, RoundUp)
    j = div(I-gr.nxny*(k-1), nx, RoundUp)
    (i, j, k)
end

# lower-front-left corner nodal index of I-th elements
cornerindex_ijk(gr::Grid{LinearMesh,M,N}, iel::Int)  where {M, N} = (
    mod(iel-1, gr.nels[1])+1,
    mod(div(iel, gr.nels[1], RoundUp)-1, gr.nels[2])+1,
    div(iel, gr.nels[1]*gr.nels[2], RoundUp),
)

function cornerindex(gr::Grid{LinearMesh,M,N}, iel::Int) where {M, N}
    nx, ny, = gr.nnods
    i, j, k = cornerindex_ijk(gr, iel)
    i + (j-1)*nx + (k-1)*nx*ny 
end

function connectivity(gr::Grid{LinearMesh,M,N}) where {M, N} 
    #=
        8_____________9
       /|            /|       
      / |           / |   
    5/__|_________6/  |
     |  |          |  | 
     |  4__________|_3|  
     |  /          |  /
     | /           | /
    1|/___________2|/

    =#
    nel = Π(gr.nels)
    e2n = Vector{NTuple{8,N}}(undef, nel)
    Threads.@threads for iel in 1:nel
        @inbounds e2n[iel] = connectivity(gr, iel) 
    end
    return e2n
end

function connectivity(gr::Grid{LinearMesh,M,N}, iel::Int) where {M, N}
    nx, ny = gr.nnods[1], gr.nnods[2]
    idx = cornerindex(gr, iel)
    #=
        8_____________9
       /|            /|       
      / |           / |   
    5/__|_________6/  |
     |  |          |  | 
     |  4__________|_3|  
     |  /          |  /
     | /           | /
    1|/___________2|/

    =#

    (
        idx,
        idx + 1,
        idx + 1 +nx,
        idx + nx,
        idx + nx*ny,
        idx + nx*ny + 1,
        idx + nx*ny + 1 + nx,
        idx + nx*ny + nx,
    )
end


