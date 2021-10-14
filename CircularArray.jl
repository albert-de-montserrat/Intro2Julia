struct CircularArray{T,N} <: AbstractArray{T,N}
    x::AbstractArray{T,N} # T: Type, N: dimension
end

Base.size(A::CircularArray) = size(A.x)

Base.length(A::CircularArray)=length(A.x)

function Base.getindex(A::CircularArray, I::Int) 
    I2 = length(A)
    return Base.getindex(A.x,  mod(I - 1,I2) + 1)
end

function Base.getindex(A::CircularArray, I::AbstractArray{Int, 1}) 
    I2 = length(A)
    return Base.getindex(A.x, @.(mod(I - 1,I2) + 1))
end

Base.getindex(A::CircularArray, I::AbstractArray{Int,1}) = (A[i] for i in I)

function Base.setindex!(A::CircularArray,value,I::Int) 
    return Base.setindex!(A.x,value,(mod.(I .- 1,I2) .+ 1))
end

Base.IndexStyle(::Type{CircularArray}) = IndexCartesian() 

a = rand(5)

b = CircularArray(a)