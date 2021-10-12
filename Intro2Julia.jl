### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ bd3c654c-ac8d-4376-be8c-7b4d39e51016
using PlutoUI

# ╔═╡ 2092b21e-d81b-46c8-82e3-190589ea034d
using BenchmarkTools # add benchmarking package

# ╔═╡ 333f966c-d6c6-444f-be49-5b14f94c5fcf
using LinearAlgebra;

# ╔═╡ 26ed158a-8546-4daa-8cfe-a6c7bfcfde57
using StaticArrays

# ╔═╡ f2d55b58-74a0-408c-b820-962de127c4df
using CUDA

# ╔═╡ eccf89a9-089f-44f6-9282-2a775205953e
using StatsPlots, Statistics

# ╔═╡ ddd2a803-07fc-40cc-8db1-e9ffc5748a73
include("StructuredGrid.jl");

# ╔═╡ 98f933cc-2b2c-11ec-068d-2395ca86fcc8
html"<button onclick='present()'>present</button>"

# ╔═╡ c66e98a8-6f98-4397-a7da-17b1c5af23c0
begin
	struct Foldable{C}
	    title::String
	    content::C
	end
	
	function Base.show(io, mime::MIME"text/html", fld::Foldable)
	    write(io,"<details><summary>$(fld.title)</summary><p>")
	    show(io, mime, fld.content)
	    write(io,"</p></details>")
	end
end

# ╔═╡ db0d3cf9-7d19-4ae6-aee3-dae408e90bc1
md"""
# Julia
- **High-level language** (MATLAB/Python) where you can do low-level (C/C++/Fortran) tunings
- **Functional** language (you can pass functions as arguments)
- **Interactive** (like MATLAB/Python)
- **Compiled** Just-In-Iime (JIT) with LLVM. MATLAB and Python are interpreted languages
- Very rich and expressive syntax
- **Dynamic typing**: no need to hard code variable types as in C/C++/Fortran
- Native multi-threading (~ OpenMP) and distributed (~ MPI) parallel libraries and supports both Nvidia and AMD GPUs
- 1-indexing
- Row major
- Macros
"""

# ╔═╡ 662d6f4f-7691-4555-8b4c-039989facdfa
md"""
# Installation
1. [Download](https://julialang.org/downloads/) Julia binaries.
2. Add path: ```export PATH="$PATH:/path/to/julia/bin"```
"""

# ╔═╡ 5b28aa47-b086-4e66-952f-6fcd3391a1e9
md"""
# Running Julia
Interaction session:
1. Type julia in your terminal
2. [VSCode](https://code.visualstudio.com/). Highly recommended

Scripts can be run from the terminal ```julia MyScript.jl```
"""

# ╔═╡ 82147a99-f8de-497c-97f9-8e354f9155ec
md"""
# Packages
Useful built-in packages include
   
   * LinearAlgebra
   * SparseArrays
   * Statistics
   * Threads
   * Distributed
   
There is also rapidly growing ecosystem of thrid-party packages that go from low-level code optimizations to ML, ODE solvers, CAS, etc. Some popular examples:
    
   * Benchmarking: BenchmarkTools.jl, TimerOutputs.jl
   * Visualization: Makie.jl, Plots.jl, UnicodePlots.jl
   * Performance boosters: StaticArrays.jl, LoopVectorization.jl
   * CUDA.jl
   * Multi-threading: Floops.jl, Polyester.jl
   * Machine-learning: Flux.jl
   * ODEs: DifferentialEquations.jl
   * Computer Algebra System (CAS; i.e. symbolic calculus): Symbolics.jl 
   * Bayesian inference: Turing.jl
## Installing packages
```] add PackageName```
or
```import Pkg; Pkg.add("PackageName")```
## Using a package
```using PackageName```
"""

# ╔═╡ 778e6689-a9a7-43d5-9aeb-55c3c1b94a09
md"""
# Main keys for code design with Julia
1. Write type-stable code
3. Do not abuse of MATLAB/Python-style vectorization, loops are fast. Most of the times looping is the best option as it allows to fusing of operations, multi-threading, vectorization, and other low-level optimizations.
4. Multiple-dispatch
"""

# ╔═╡ bdfa6d39-9b42-4fda-a9c4-2314cad5a373
md"""
# Main annoying differences coming from MATLAB

* Arrays are indixed with squared brackets ```A[i,j]```
* In matlab ```A==B``` returns a boolean vector, Julia returns a **scalar** boolean (```true``` or ```false```). The boolean vector is obtained with ```A.==B```
* In MATLAB ```1:10``` allocates a vector while Julia produces a lazy structure. To allocate a vector use ```collect(1:10)```.
* Don't use ```;``` to break a code line. an intro will do.
* Arrays are not resized automatically. I.e. ```x=rand(10); x[11] = rand()``` will throw an error. Use ```push!()``` (e.g.```push!(x, rand())```) to concatenate values to an array and ```pop!()``` to empty array indices.
* In MATLAB, a vector $$v\in\mathbb{R}^n$$ is actually a matrix $$v\in\mathbb{R}^{n\times 1}$$. In Julia $$v$$ is actually a vector.
"""

# ╔═╡ 9b333b08-9939-461b-aa3b-a458e62fae40
a=1; b=a; b=2;

# ╔═╡ cb5f35f8-cf9b-4e24-94fa-c1a873fb38e5
Foldable("a ?", md"a=$a")

# ╔═╡ eb36d356-dd00-416e-825e-d687a43f886b
c=[1,2]; d=c; d[1]=9;

# ╔═╡ d8da9239-952d-4c08-a713-22e0a8806e64
Foldable("c ?", md"$c")

# ╔═╡ feff3764-49c0-496e-b79b-c372c86d8c28
md"""
# Functions
Functions are constructed more or less like in MATLAB. The standard syntax is:
"""

# ╔═╡ 83a6e288-75e8-4b50-b2a0-10a41e6b9ec3
function ho_sete(bitter)
    spriss = string("Spriss ", bitter) 
    return spriss
end;

# ╔═╡ 7ae76c15-ca40-421b-9030-59556a3b5199
md"""
Alternative syntaxes:
"""

# ╔═╡ 509f130e-783c-475f-9847-da66e880f527
function ho_sete2(bitter)
    spriss = string("Spriss", bitter) 
end;

# ╔═╡ c75feadb-284e-4fbf-88dd-0355ef1a9453
ho_sete3(bitter) = string("Spriss", bitter);

# ╔═╡ a9910c18-8c67-48e9-b522-b0c468d6cb59
md"""
# Arrays

They are 1-based index and columm major (as in MATLAB/Fortran). 
"""

# ╔═╡ 1d751826-c02c-4202-a02d-c16741804923
fill(1.5, 3) # fill(value, number of elements)

# ╔═╡ 4a436609-0642-4ae6-91cd-19fcd58a085e
zeros(3) # default is Float64, can do zeros(T, n) where T is the type

# ╔═╡ c135540c-553d-4680-a939-f07be566684e
rand(3) # default is Float64, can do rand(T, n) where T is the type

# ╔═╡ 79d5b308-5152-4aaa-a9ca-f07043f43b9b
x = Array{Float64,1}(undef, 3) # Array{Type}(undef, number of elements of i-th dimension) → fastest way to allocate empty array

# ╔═╡ 2afd08a4-2317-4157-b3af-052c37a90201
md"""
In-place filling of an array:
"""

# ╔═╡ 931f7397-aebf-4675-bedc-66eaa753f16d
fill!(x, rand())

# ╔═╡ ff7d609d-e7ed-47e7-a32e-c4ccd6841a8d
md"""
**REMAINDER**: $$x_i$$ is a one-dimensional **array** of size $$3$$. $$x_i$$ would be a $$3 \times 1$$ **matrix** in MATLAB . It is important because a vector is of type Array{T,1} while a matrix is Array{T,2}.
"""

# ╔═╡ bc9be966-7a01-40f2-85fe-a5bcfb15dd39
md"""
## Slicing
"""

# ╔═╡ 517e34d4-d9d8-4c98-b488-7e413cf90546
x[1:2] # this allocates a new array, avoid in production code

# ╔═╡ 21a808a7-50c0-4597-9e7e-f8cb3f3f0dfb
@views x[1:2] # no allocation, recommended for 99.9% of the cases. Alternative syntax: view(x, 11:2)

# ╔═╡ f20592db-5c2c-4a92-86af-d68fe4602139
md"""
# Broadcasting
Opposite to MATLAB, Julia **does not** automatically broadcast functions over arrays. To broadcast we need to introduce a dot between function call and arguments
"""

# ╔═╡ ec7e9af3-f419-4855-b1b8-5cffa8a48c06
sin.(x).*exp.(x)

# ╔═╡ df216392-a6c9-4742-8d8e-f6bdcb824961
md"""
We can use the macro ```@.``` to fuse all the dots and have a more compact expression which is usually more performant.
"""

# ╔═╡ ca64cf39-e99d-4de7-ba96-47869a8fd32f
@. sin(x)*exp(x)

# ╔═╡ bf6fa75b-c3d2-4e59-bc27-aa8b14dfa293
md"""
# Benchmarking
"""

# ╔═╡ e1c71f8d-60e6-43ae-8668-7e79905cafaf
md"""
Functions can easily be benchmarked with macros ```@benchmark``` and ```@btime``` provided by [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). For examaple, let's consider the spatial derivative of a function as:

$$f(x, y)' \approx \frac{f(x + \Delta x,y) - f(x - \Delta x,y)}{2\Delta x}$$

We can write it almost as in MATLAB:
"""

# ╔═╡ ceaa4f8c-18a9-487f-911a-da8252acc7ec
dxdy1(x,y) = @. (y[3:end] - y[1:end-2])*0.5/(x[2]-x[1]);

# ╔═╡ bc310c73-d166-49d4-bfc8-de3d792af59f
vx = LinRange(0, 2π, 1_000); vy = sin.(vx); # we can use Unicode symbols such as π

# ╔═╡ 62212f88-9e1b-41a0-b74f-04d814660c71
@benchmark dxdy1($vx, $vy)

# ╔═╡ a9151ef1-32b7-42f9-9c99-69aeda6294aa
md"""
In the function above ```y[3:end]``` and ```y[1:end-2]``` allocate 2 new arrays. We can avoid it using ```@views```
"""

# ╔═╡ e675ac4f-43ed-4ba2-a70c-d951ef077da6
dxdy2(x,y) = @views @. (y[3:end] - y[1:end-2])*0.5/(x[2]-x[1]);

# ╔═╡ 5a198e14-d87b-44e5-b330-ba66b7dd9288
@benchmark dxdy2($vx, $vy) # ~3 times faster, a single allocation 

# ╔═╡ 8d307ccb-3ad1-4d4d-b56e-aca8583e4a0a
md"""
# Linear Algebra
Most of linear algebra operations are in the ```LinearAlgebra``` [package](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/). This package contains bindings for most (all?) BLAS [level 1, 2, 3 functions](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms), linear solvers, eigenvalues and eigenvectors. To add linear algebra for sparse arrays use the ```SparseArrays``` package. 
"""

# ╔═╡ ca8a1df6-15f9-46a7-9b46-f2448d54dbc9
A, B, v = rand(4,4), rand(4,4), rand(4);

# ╔═╡ 347af98d-b8a3-484e-8e7b-d7cc9fe989c3
A' # or transpose(A)

# ╔═╡ 6ef36d0e-1195-43f9-b165-93ef22b06b57
A*B # this calls OpenBlas for dense arrays

# ╔═╡ 285ecde5-7cc8-42e8-bee0-efe06003713b
A*v # this calls OpenBlas for dense arrays

# ╔═╡ c52e48fa-e742-4ff4-a5ac-55b344b16375
v ⋅ v # dot product (or dot(v,v) )

# ╔═╡ 1c80661e-a9df-47aa-899f-5c7eb79a050d
det(A)

# ╔═╡ d04d45e5-87b2-4f76-b0f8-d9a415608f03
A\v # this calls LAPACK for dense arrays and SuitSparse for sparse arrays

# ╔═╡ 1165c3cb-c90b-4dfb-b7dc-36f3f47b7b65
md"""
# Loops
Unlike in MATLAB and Python, loops are **FAST** (comparable to C/C++/Fortran) and mos of the times more readable than _vectorised_ code, so don't be scared of using them.
"""

# ╔═╡ 1464378c-e00a-49f5-9a45-771d7e3968e0
for i in 1:length(x) 
    sin(x[i])*exp(x[i]);
end;

# ╔═╡ 01a510ae-1d26-4fb1-9203-c0c72c534447
for i in eachindex(x) # you can use "=" instead of "in"
    sin(x[i])*exp(x[i]);
end;

# ╔═╡ e369cc85-f207-4768-8c8e-9e70779656bd
for xi in x 
    sin(xi)*exp(xi);
end;

# ╔═╡ ac492a93-4db2-4090-8a85-7b4af63606fd
y = similar(x); # allocates array with type and size of x 

# ╔═╡ ebcb05bf-1ff6-4dc3-bcc3-ab4dabaa741a
for (i, xi) in enumerate(x) 
    y[i] = sin(xi)*exp(xi);
end;

# ╔═╡ 0bbf8c5c-468e-495b-88b6-4bd1ec007f97
for (xi, yi) in zip(x, y) 
    sin(xi)*exp(yi);
end;

# ╔═╡ 174b80e8-dddb-4f3f-9dbf-19b7ccf7b696
md"""
Use the macro ```@inbound``` to tell the compiler not to check if the index is within the bounds of the array. **Warning** this is unsafe and may result in a segfault, do only when you know the loop is correct.
"""

# ╔═╡ c069a4a4-acaf-4611-ad8f-177d82964219
@inbounds for i in 1:length(x) 
    sin(x[i])*exp(x[i]);
end;

# ╔═╡ 30d283b3-c45e-47c6-bbc5-30c908df4779
md"""
# Types
In dynamic languages such as MATLAB/Python, one does not need to think too much about the types of the variables. On the other hand, in static languages (C/C++/Fortran) the types of any single variable must be declared. Some classic primitive types common in programming languages are ```Integers```, ```Floats```, ```String```, ```Complex```, etc. In Julia the user can choose to declare or not the types, however they play a pivotal role in the intrinsics of the language:
1. **Type stability**. To generate highly optimized code, the compiler needs to be able to infer the type of the variables at compile-time.
2. **Multiple-dispatch** A single function can have many different methods, that are dispatched according to the number of arguments and/or their types.
"""

# ╔═╡ c17cfcb8-01c0-41dd-a6b0-230f1e399cfb
md"""

## Type stability
Julia's performance depends heavily on type inference, the ability of compiler to know ahead-of-time the types of the arguments. In a simplistic way, this means that the types of an object should not mutate or be unknown at compile-time. Let's consider the following function:
"""

# ╔═╡ 24a81d95-8f34-4501-a99e-1f130d39ba12
function f1(a)
    if a < 0
        return 0 # returns only zero of type ::Int64 
    else
        return a # returns a::T
    end
end;

# ╔═╡ 52bde5e2-56e6-42d2-9637-493964e6b398
f1(1.2)

# ╔═╡ f80212c5-92de-4908-b478-1f4cb7942afd
typeof(f1(1.2))

# ╔═╡ 78de9938-04b4-4d7a-b9e7-b3a1f437f1b2
f1(-1.2)

# ╔═╡ 12b33efc-f3ad-4af2-ad89-54e471a651c8
typeof(f1(-1.2))

# ╔═╡ 439457a1-b98f-4802-966a-101bb09fbb33
md"""
We can use the ```@code_warntype``` macro to quickly look for type unstabilities
"""

# ╔═╡ f0ea868f-6a08-49c5-87c4-42931e163d0e
with_terminal() do 
	@code_warntype f1(1.2)
end

# ╔═╡ 58efe369-7f11-4a37-9c99-5f75a28f112a
md"""
How to fix it:
"""

# ╔═╡ 9531e6c5-7249-403c-8fdb-6cf8b95985fe
function f2(a::T) where T # T is the type of a, which can be anything in this case
    if a < 0
        return zero(T) # now it returns a zero of the same type of a (i.e. known at compile-time)
    else
        return a # returns a::T
    end
end;

# ╔═╡ b8124d20-60db-4e7b-ae45-82516c0f7d53
with_terminal() do 
	@code_warntype f2(1.2) # compiler is happy
end

# ╔═╡ 59ec6809-e944-4b68-959a-fa5154ed37f7
md"""
Type unstability raising from a type mutation:
"""

# ╔═╡ d8d27f57-2355-4a7a-9286-c0cf27c08138
function g1(v::Vector{T}) where T
    a = rand(T, length(v), length(v))
    v = @. v*a # we are mutating v from Array{T,1} → Array{T,2}
end;

# ╔═╡ a99b82cd-bcc8-47d1-86d2-4526ed396da0
with_terminal() do 
	@code_warntype g1(rand(5))
end

# ╔═╡ 3b7d5a9b-6d6d-459c-818d-61dd413970f1
function g2(v::Vector{T}) where T
    a = rand(T, length(v), length(v))
    v2 = @. v*a # we are mutating v from Array{T,1} → Array{T,2}
end;

# ╔═╡ efac8b14-0512-492e-a18a-95e2897b89f1
with_terminal() do 
	@code_warntype g2(rand(5))
end

# ╔═╡ ec46e371-4ec7-4fea-969e-1c1306e960b4
md"""
## Custom Types (a.k.a structures)
New types are defined in a similar manner as in C/C++. For example we can define our custom Point data type
"""

# ╔═╡ be8c9830-f61a-4935-ad7d-f17bf3ceefe0
struct myPoint1
    x
    z
end;

# ╔═╡ 180241c8-2d4d-4217-b592-3c630237919a
md"""
This definition is way too generic, as $x$ and $z$ can be literally anything, which makes the compiler rather unhappy. It is much better to define their types
"""

# ╔═╡ 80f2cac1-f9cb-4b7a-a592-d1ef51bb5bb2
struct myPoint2
    x::Float64
    z::Float64
end;

# ╔═╡ f6691fe6-dce3-43dd-8fe3-a30d3edbb447
md"""
Now the problem is that myPoint2 is way too stiff and works only for double precision floats. We can instead make a general purpose parametric type
"""

# ╔═╡ 91280610-a60f-4fa5-bc46-7f490ac29d6c
struct myPoint{T}
    x::T
    z::T
end;

# ╔═╡ a4ac1650-2fad-4de0-a4a6-b68842719d7c
md"""
Our structure is of type T, where T is given by the type of $x$ and $z$
"""

# ╔═╡ 9dbf3677-fdc3-47d8-b87e-33e314aa0fc3
myPoint(1, 2)

# ╔═╡ 020f91be-3e5d-49ef-8524-ccc91d1b1143
myPoint(1.0, 2.0)

# ╔═╡ 6aa86405-31db-4485-bb02-d613e9d5c9d6
md"""
# Classic OOP vs Multiple Dispatch
"""

# ╔═╡ 1acfa505-fa6c-45b9-9d6b-092c762eb94e
md"""
In classic Object-Oriented Programming (OOP) (i.e. C++, Python, Rust) one defines a Class (similar to Julia's ```Structure```) and methods are attached to the Class. There is no separation between class and methods, they are bounded together. Python example:

```Python
class Dog:
    species = "Canis familiaris"

    def __init__(self, name, age):
        self.name = name
        self.age = age

    # Instance method
    def description(self):
        return f"{self.name} is {self.age} years old"
```

```Python
>>> miles = Dog("Miles", 4)

>>> miles.description()
'Miles is 4 years old'
```
"""

# ╔═╡ 63beb9af-5763-4db0-a64d-74247d30c3f8
md"""
Julia's Multiple Dispatch approach is different and Classes and Methods are completely separated. In Multiple Dispatch a function ```f()``` can have different methods, which depend on the number and type of the arguments. E.g. defining first ```f(x)``` and later ```f(x,y)``` does not over-ride ```f(x)```, it just adds a new method to ```f()```.

Multiple dispatch is one of the most powerful tools in Julia. Let's consider we have two points $a$ and $b$ of type ```{myPoint}``` and we want to sum them. Obviously we cannot sum them directly as $a+b$, but we can add a new method to the built-in ```+``` function (this is called function overload):
"""

# ╔═╡ cd24a29a-c240-4a4f-97a6-abc99b439b90
begin
	import .Base:+ # to overload a built-in function, we need to import it from the Base library 
	+(a::myPoint,b::myPoint) = myPoint(a.x+b.x, a.z+b.z); # we added a new method for '+' for arguments of type {myPoint}
end;

# ╔═╡ c935a6db-ed98-4f01-8e41-b6bd903f7a16
# cholesky (LLᵀ) factorization needs a SPD matrix, which can be generated by 
# multiplying A times its transpose and augmenting it with the identity matrix I
F = cholesky(A*A' + I); # LAPACK for dense arrays and SuitSparse for sparse arrays

# ╔═╡ d2a9fa6c-9aa5-4818-8746-4fc4142a34ee
F.L

# ╔═╡ 14634323-48d4-4481-ae6f-602913747220
F.U

# ╔═╡ 25648ad4-facb-4181-864d-75241c6c982b
p1, p2 = myPoint(1.0, 2.0), myPoint(7.0, 3.0);

# ╔═╡ cfb50811-f5e2-4dae-8424-db9bcf601ab4
p1+p2

# ╔═╡ 84e023b8-0503-4e45-a782-c110fd08bb03
md"""
## Subtyping
Types have a hierarchy were several subtypes can share a common supertype. For example ```Int32``` and ```Int64``` are both subtypes of ```Integer```, while ```Integer``` is a subtype of ```Real```. We can define new supertypes and subtypes to our convinience. We can illustrate it expanding our first example.
"""

# ╔═╡ 81f040bf-d4d1-4997-8303-d9f2f6254404
begin
	# Supertype (e.g.) type at the top of the hierarchy chain
	abstract type Alcohol end
	
	# We start spliting Alochol in two secondary supertypes
	abstract type Spritz <: Alcohol end # Every kind of spritz will be a subtype of {Spritz}
	abstract type Cocktail <: Alcohol end # Cocktails will be a subtype of {Cocktail}
	abstract type Beer <: Alcohol end # Cocktails will be a subtype of {Beer}

	# Subtypes of Spritz
	abstract type Cynar <: Spritz end
	abstract type Select <: Spritz end 
	abstract type Campari <: Spritz end 
	
	# Subtypes of Coktail 
	abstract type Negroni <: Cocktail end
	abstract type GinTonic <: Cocktail end
	abstract type FrancaCola <: Cocktail end 
end

# ╔═╡ feebbec0-777b-43ca-8252-dbd814c8f84e
struct Drink{T<:Alcohol} end # define Drink class of Supertype {Alcohol}

# ╔═╡ 006db471-9ed1-424f-a43e-66e5dc0a8af9
begin
	ho_sete(::Type{Drink{T}}) where T<:Spritz = string("Portami un spriss $T")
	ho_sete(::Type{Drink{T}}) where T<:Cocktail = string("Voglio ubriacarme con un $T")
	ho_sete(::Type{Drink{T}}) where T<:FrancaCola = string("Franca-Cola fa cagare")
end

# ╔═╡ 298f446d-6d6e-44f1-9482-abc70d07ab5d
ho_sete("Cynar")

# ╔═╡ cf5ddd6e-faf3-4338-8c83-bd734b0caa1e
ho_sete(Drink{Cynar})

# ╔═╡ 6a2a698c-1178-4916-98e4-3d8dd954892e
ho_sete(Drink{FrancaCola})

# ╔═╡ e45480b6-98d9-45c6-a4fa-a22df5142aec
md"""
# Stack vs Heap
A nice description of the Stack and Heap is found in [Rust's documentation](http://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/book/first-edition/the-stack-and-the-heap.html). Long story short:

* Stack:
  * Fast
  * Does not really allocate memory
  * Limited size → can overflow
  * De-allocated automatically when variable is out of scope

* Heap:
  * Slow
  * Limited only by available RAM
  * It does not de-allocate automatically → responsible for memory leaks in C/C++


In MATLAB/Python arrays are allocated in the heap so nothing to do or worry here. In C/C++ one has to be careful and decide to stack or heap allocate. In Julia all the scalars go to the stack, and all the standard arrays go to the heap. Julia has a Garbage Collector (GC) that runs periodically to de-allocate unused heap memory, so we don't have to worry about memory leaks at expenses of some time spend on the GC.

For performance, one should try to prioritize pushing variables to the stack (with care, we don't want to overflow). Julia can't push arrays to the stack, but we can insted use ```tuples```, which are basically a collection of scalars. Some algebraic operations over like ```dot()``` are built-in, but many other (i.e. matrix-matrix/vector multiplication) are missing.
"""

# ╔═╡ c360a3e3-c4c4-42b1-9d78-68c4f7e9abc9
begin
	t1 = (1, 2) # standard tuple::NTuple{2, Int64}
	t1[1]
end

# ╔═╡ 9e7ddefe-06f3-4c77-a419-0317b0cfcfb2
begin
	t2 = (a=1, b=2) # NamedTuple, similar to a structure
	t2.a
end

# ╔═╡ 63ed0f91-5b00-43a6-ba59-09f7b8465cd8
t1 ⋅ t1 # dot product of tuples

# ╔═╡ 4e0dfdd0-010d-4a2d-9f23-4b87f62f42ba
md"""
These missing functions are supported by [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl), which is a API for tuples that behave like arrays. It overloads most of the functions in ```LinearAlgebra``` with optimized SIMD algorithms. The size of the stack is much smaller than the heap, so use it only for $A\in\mathbb{R}^{m\times n}$ or $x\in\mathbb{R}^{m}$ with $m,n<50$.
"""

# ╔═╡ 30291f06-b120-46d8-a197-0f2d11153134
begin
	As = @SMatrix rand(4,4)
	Bs = @SMatrix rand(4,4)
	vs = @SVector rand(4)
end

# ╔═╡ fab2d08a-b62e-4d83-9a8c-a2d71f246974
md"""
Matrix multiplication
"""

# ╔═╡ 99f9e29a-b018-474a-aad9-4251b584303c
@benchmark A*B # heap arrays

# ╔═╡ c1257a02-48cd-4c6d-8ce0-5beaab138342
@benchmark As*Bs # stack arrays

# ╔═╡ d13e75de-2cb5-48bd-966b-2aa8702dec26
md"""
Matrix-vector multiplication
"""

# ╔═╡ a254406e-7579-4ec1-9c46-bed389cd046a
@benchmark A*v # heap arrays

# ╔═╡ 591cadf3-68e7-4dd4-bd9e-ddae1795fe42
@benchmark As*vs # stack arrays

# ╔═╡ 4468400e-3f7c-45e7-bbf0-c7100da2810c
md"""
# Multi-threading
Julia has its own [multi-threading](https://docs.julialang.org/en/v1/base/multi-threading/) (~OpenMP) package. It's usage is straightforward, however, be careful because does not the parallel loops are **NOT THREAD-SAFE**. Tip for perfomance: try to minimize as hard as possible the number of memory allocations occurring inside threaded loops.
"""

# ╔═╡ f3cdd5e9-20ec-417c-9b3e-34f381352fb0
function ft1(x::AbstractArray)
    Threads.@threads for i in eachindex(x) # Macro Threads.@threads multithreads the loop
        x[i] = sin(x[i]) # no race condition here, we are good
    end
    x
end;

# ╔═╡ fb12053c-e8be-418c-b62a-17934c74f079
function ft2(x::AbstractArray)
    a = zero(eltype(x)) # make a zero of the type of the elements in x
    Threads.@threads for i in eachindex(x)
        a += sin(x[i]) # there are race conditions here, the function will produce different results
    end
    a
end;

# ╔═╡ 23814e8e-185b-4550-97c4-f4aa418571d6
function ft3(M::Matrix)
    Threads.@threads for j in size(M,2) # only the outer loop is threaded, bad for performance
        for i in size(M,1)
            M[i,j] += sin(M[i,j]) # thread-safe
        end
    end
    M
end;

# ╔═╡ d4efea27-464e-416c-97cc-58302d5ec829
function ft4(M::Matrix)
    Threads.@threads for I in eachindex(M) # can use linear indices and parallelize the whole function
        M[I] += sin(M[I]) # thread-safe
    end
    M
end;

# ╔═╡ 6605a311-2bfb-4ad8-a678-fdbdb826dd32
md"""
# Basic GPU programming
Both Nvidia and AMD [GPUs](https://github.com/JuliaGPU) are supported by Julia. If you have an Nvidia GPU card you can uncomment the code snippets below and add [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl), otherwise the notebook might crash.
"""

# ╔═╡ a6aed0b2-882c-44bd-96f3-aff42e0062af
# Ad, Bd, vd = CuArray(A), CuArray(B), CuArray(v);

# ╔═╡ 2ac430a3-8922-4be0-a8ae-a87ec3ad7ff6
# Ad*Bd

# ╔═╡ ece321e3-c1fe-41a9-99e4-168c9420f8ce
# map(sin, vd) # somehow this crashes in Pluto

# ╔═╡ dd1cf62c-5d88-4769-af81-4d054c8a533c
# cholesky(Ad*Ad'+I)

# ╔═╡ 93d584fe-3c2c-4849-ac60-45888767948d
md"""
For Krylov subspace iterative solvers (e.g. Conjugate Gradients, GMRES, lsqr,..) with GPU support check [Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl)
"""

# ╔═╡ 75eb6eb7-2b51-43a6-b5bb-4a7068de55b7
md"""
# Tips for performant code
1. Most of the times, the largest contributor to performance is the choice of the algorithm.
2. **Understad memory how memory works** 
   * Understand when Julia allocates memory (e.g. ```x[1:50]*y[1:50]``` allocates two temporary arrays) 
   * Usually biggest problem if you come from MATLAB where you don't think about it
   * In-place operations whenever possible. Allocate buffers if needed.
   * Critical in parallel code. Allocate buffers if needed.
3. Parallelize the code at the appropriate scale (usually at the coarsest scale possible so that threads live is longer)
4. Implementation. E.g:
    * Iterate always first along the first index of an array
    * Understand when you can push to the stack (use and abuse of tuples) instead of heap-arrays
    * Prioritize in-place operations
    * Avoid redundant calculations
5. Micro-optimization. E.g.:
    * Multiplication is faster than division
    * Powers, roots, exponentials and trigonometric functions are slow. Simplify expressions as much as possible (use symbolic calculus)
5. Hardware optimizations. E.g.:
    * Fuse-multiply add (fma): fast algorithm to calculate ```fma(a,b,c) = a*b+c```. Supported by most of the CPUs. For complex expressions use the ```@muladd``` [macro](https://github.com/SciML/MuladdMacro.jl)
    * Vectorize loops with the macros ```@turbo``` (single-thread) ```@tturbo``` (multi-thread) from [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)
"""

# ╔═╡ 6b08d896-cdb1-4c3a-bec8-3922eaaac279
md"""
# Example: 3D structured mesh API
"""

# ╔═╡ 559e468f-1970-458b-a9f9-a7fb08291bd1
begin
	c0 = (0f0, 0f0, 0f0) # origin corner
	c1 = (1f0, 1f0, 1f0) # opposite corner
	nels = (100, 100, 100) # number of elements per cartesian axis
	# nels = (33, 80, 50) # number of elements per cartesian axis
	nnods = nels .+ 1 # number of nodes per cartesian axis
	gr = grid(c0, c1, nnods, LinearMesh); # generate grid
end;

# ╔═╡ 476cb592-cb57-4691-9656-0af55b473b5f
gr[2,3,1]

# ╔═╡ 420c82bd-eea5-4408-8ec1-0e27ad1d35e4
gr[1]

# ╔═╡ 2550e29b-a9bb-4de7-8f5f-7f4c1e0ed55f
connectivity(gr, 1) # node numbers of a single cell

# ╔═╡ 64b20b98-2733-447f-8d2b-cd3ee32f302c
connectivity(gr) # whole mesh connectivity matrix

# ╔═╡ dd079685-283c-4a3b-959b-75200368afb1
md"""
Let's say we want to do the following operation in every node of the grid:

$$f(x_i,y_i,z_i)=\sin(x_i)\exp(y_i)z_i^3$$
"""

# ╔═╡ 362e660b-d069-406a-9028-90385f69fedd
f(X::Point) = sin(X.x)*exp(X.y)*(X.z^3); # X = (xᵢ, yᵢ, zᵢ) 

# ╔═╡ 8afe67c7-a91c-4182-b2d2-8a51ec70e38e
function gcart(gr) # Loop over grid using cartesian indices
    nx, ny, nz = gr.nnods
    nxny = gr.nxny # total number of nodes
    out = Vector{Float32}(undef, Π(gr.nnods)) # allocate output
	
    for i in 1:nx, j in 1:ny, k in 1:nz
        idx = i + ny*(j-1) + nxny*(k-1) # global index
        @inbounds out[idx] = f(gr[i,j,k])
    end
end

# ╔═╡ 1556443c-acbe-47b4-8913-00063c06fe90
function glinear(gr) # Loop over grid using linear indices
    n = Π(gr.nnods) 
    out = Vector{Float32}(undef, n) # allocate output
    for i in 1:n
        @inbounds out[i] = f(gr[i])
    end
end

# ╔═╡ f653bdfa-ebdd-4e71-92f1-ee905cce6efe
function gcart_thread(gr) # Loop over grid using cartesian indices in parallel
    nx, ny, nz = gr.nnods
    nxny = gr.nxny
    out = Vector{Float32}(undef, Π(gr.nnods)) # allocate output
	
    Threads.@threads for i in 1:nx
        for j in 1:ny, k in 1:nz
            idx = i + ny*(j-1) + nxny*(k-1) # global index
            @inbounds out[idx] = f(gr[i,j,k])
        end
    end
end

# ╔═╡ 6e2ccb33-6eda-4632-9c91-3047235f6817
function glinear_thread(gr) # Loop over grid using linear indices in parallel
    n = Π(gr.nnods) # total number of nodes
    out = Vector{Float32}(undef, n) # allocate output
	
    Threads.@threads for i in 1:n
        @inbounds out[i] = f(gr[i])
    end
end

# ╔═╡ 6a78dd1b-af8d-44ff-a51d-c15440752a1d
md"""
## Benchmarks
Cartesian indices
"""

# ╔═╡ b53c61f8-a52b-4455-b997-0f123a5837ae
bcart = @benchmark gcart($gr) 

# ╔═╡ 59598425-3c7b-41de-9533-4575529d15ca
md"""
Linear indices
"""

# ╔═╡ a2176faf-e599-4799-8f4d-2fd5160364e2
blinear = @benchmark glinear($gr)

# ╔═╡ 20f2b901-f05d-44c9-a3fb-d49121c59b89
md"""
Cartesian indices in parallel
"""

# ╔═╡ 65a64e45-a135-4b40-9751-def260671bff
bcart_thread = @benchmark gcart_thread($gr) 

# ╔═╡ 43dc8d45-ba68-435a-b613-d7d1370f5e34
md"""
Linear indices in parallel
"""

# ╔═╡ 102f42e8-7973-433f-be87-aefed240441a
blinear_thread =@benchmark glinear_thread($gr) 

# ╔═╡ 1accef19-60ac-4ac9-85ad-1f45f8b454ed
md"""
## Can we do better?
```gr``` is an object that contains 3 arrays $x$, $y$ and $z$ that are allocated when ```gr``` is instantiated. We actually do not need to allocate any array. Instead we can create a lazy object instead, given that we know one corner of the grid and the distance between consecutive nodes.
"""

# ╔═╡ eb553be0-c7f0-423a-a125-5bfd4e07b13a
gl = lazy_grid(c0, c1, nnods); # generate lazy grid

# ╔═╡ 05802136-7ec1-4468-b82a-3d673436d57e
string(Base.summarysize(gr)/1e3, " KiB")

# ╔═╡ a9e3d8b7-cfbe-4f86-8d15-4ac02e18d203
string(Base.summarysize(gl)/1e3, " KiB")

# ╔═╡ 4aa80c7c-c0aa-40ef-ab62-5d4a04a6fda5
lcart =@benchmark gcart($gl) 

# ╔═╡ f4334a01-537a-4720-866f-f4709e656dda
llinear =@benchmark glinear($gl) 

# ╔═╡ 3b8619a1-a358-409c-9503-10b0f6270a9c
lcart_thread =@benchmark gcart_thread($gl) 

# ╔═╡ 4846a032-c374-4bd5-8426-f67a029522d5
llinear_thread =@benchmark glinear_thread($gl) 

# ╔═╡ d222c0e6-696f-41aa-897a-a0ec4b8fdb68
md"""
## Grid benchmarks visualization
"""

# ╔═╡ 6745369d-25ed-432e-95c0-30b648596aaf
time_cartesian = [
	mean(bcart.times),
	mean(bcart_thread.times),
	mean(lcart.times),
	mean(lcart_thread.times)
].*1e-6;

# ╔═╡ 5f2c5759-768f-4fd5-a8bf-24cdea487f64
time_linear = [
	mean(blinear.times),
	mean(blinear_thread.times),
	mean(llinear.times),
	mean(llinear_thread.times)
].*1e-6;

# ╔═╡ 2270edc1-ef05-4e29-ab46-2093041831b7
ticklabel = [
	"1 thread",
	"4 threads",
	"lazy grid, 1 thread",
	"lazy grid, 4 thread",
];

# ╔═╡ df89214c-2c73-4842-9893-a87f34a04be1
gp = repeat(["cartesian", "linear"], inner = 4); # legend

# ╔═╡ e0bfff4e-6c2e-4032-b447-07bd956da66e
groupedbar([time_cartesian time_linear], group = gp, bar_position = :dodge, bar_width=0.7, xticks=(1:4, ticklabel), ylabel="μs")

# ╔═╡ 98c640aa-72c3-43b0-adf2-183022251ec7
speedup(t) = [1, t[1]/t[2], 1, t[3]/t[4]];

# ╔═╡ 08116d16-d041-406c-b41d-8c91b5e68040
speedup_cartesian = speedup(time_cartesian);

# ╔═╡ 2e816f20-9d5e-4782-8a06-fa7e1ca9f7c5
speedup_linear = speedup(time_linear);

# ╔═╡ 88531bc9-0cd7-4bdd-a6e8-1487772eb008
groupedbar([speedup_cartesian speedup_linear], group = gp, bar_position = :dodge, bar_width=0.7, xticks=(1:4, ticklabel), ylabel="speed up", legend=:topleft)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
BenchmarkTools = "~1.2.0"
CUDA = "~3.5.0"
PlutoUI = "~0.7.16"
StaticArrays = "~1.2.13"
StatsPlots = "~0.14.28"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0-rc1"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[deps.Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "2c8329f16addffd09e6ca84c556e2185a4933c64"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.5.0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "a325370b9dd0e6bf5656a6f1a7ae80755f8ccc46"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.7.2"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "9f46deb4d4ee4494ffb5a40a27a2aced67bdd838"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.4"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "e13d3977b559f013b3729a029119162f84e93f5b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.19"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[deps.GPUArrays]]
deps = ["Adapt", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "7772508f17f1d482fe0df72cabc5b55bec06bbe0"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.1.2"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "2c7c032f2940f45ab44df765a7333026927afa00"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.13.5"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[deps.IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "46092047ca4edc10720ecab437c42283cd7c44f3"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.6.0"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6a2af408fe809c4f1a54d2b3f188fdd3698549d6"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.11+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[deps.NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0e9e582987d36d5a61e650e6e543b9e44d9914b"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "6841db754bd01a91d281370d9a0f8787e220ae08"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.4"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Libdl", "Random", "RandomNumbers"]
git-tree-sha1 = "0e8b146557ad1c6deb1367655e052276690e71a3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.4.2"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[deps.RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "793793f1df98e3d7d554b65a107e9c9a6399a6ed"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.7.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "65fb73045d0e9aaa39ea9a29a5e7506d9ef6511f"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.11"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[deps.StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "eb007bb78d8a46ab98cd14188e3cec139a4476cf"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.28"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "019acfd5a4a6c5f0f38de69f2ff7ed527f1881da"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.1.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9398e8fefd83bde121d5127114bd3b6762c764a6"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.4"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─98f933cc-2b2c-11ec-068d-2395ca86fcc8
# ╟─bd3c654c-ac8d-4376-be8c-7b4d39e51016
# ╟─c66e98a8-6f98-4397-a7da-17b1c5af23c0
# ╟─db0d3cf9-7d19-4ae6-aee3-dae408e90bc1
# ╟─662d6f4f-7691-4555-8b4c-039989facdfa
# ╟─5b28aa47-b086-4e66-952f-6fcd3391a1e9
# ╟─82147a99-f8de-497c-97f9-8e354f9155ec
# ╟─778e6689-a9a7-43d5-9aeb-55c3c1b94a09
# ╟─bdfa6d39-9b42-4fda-a9c4-2314cad5a373
# ╠═9b333b08-9939-461b-aa3b-a458e62fae40
# ╟─cb5f35f8-cf9b-4e24-94fa-c1a873fb38e5
# ╠═eb36d356-dd00-416e-825e-d687a43f886b
# ╟─d8da9239-952d-4c08-a713-22e0a8806e64
# ╟─feff3764-49c0-496e-b79b-c372c86d8c28
# ╠═83a6e288-75e8-4b50-b2a0-10a41e6b9ec3
# ╠═298f446d-6d6e-44f1-9482-abc70d07ab5d
# ╟─7ae76c15-ca40-421b-9030-59556a3b5199
# ╠═509f130e-783c-475f-9847-da66e880f527
# ╠═c75feadb-284e-4fbf-88dd-0355ef1a9453
# ╟─a9910c18-8c67-48e9-b522-b0c468d6cb59
# ╠═1d751826-c02c-4202-a02d-c16741804923
# ╠═4a436609-0642-4ae6-91cd-19fcd58a085e
# ╠═c135540c-553d-4680-a939-f07be566684e
# ╠═79d5b308-5152-4aaa-a9ca-f07043f43b9b
# ╟─2afd08a4-2317-4157-b3af-052c37a90201
# ╠═931f7397-aebf-4675-bedc-66eaa753f16d
# ╟─ff7d609d-e7ed-47e7-a32e-c4ccd6841a8d
# ╟─bc9be966-7a01-40f2-85fe-a5bcfb15dd39
# ╠═517e34d4-d9d8-4c98-b488-7e413cf90546
# ╠═21a808a7-50c0-4597-9e7e-f8cb3f3f0dfb
# ╟─f20592db-5c2c-4a92-86af-d68fe4602139
# ╠═ec7e9af3-f419-4855-b1b8-5cffa8a48c06
# ╟─df216392-a6c9-4742-8d8e-f6bdcb824961
# ╠═ca64cf39-e99d-4de7-ba96-47869a8fd32f
# ╟─bf6fa75b-c3d2-4e59-bc27-aa8b14dfa293
# ╠═e1c71f8d-60e6-43ae-8668-7e79905cafaf
# ╠═ceaa4f8c-18a9-487f-911a-da8252acc7ec
# ╠═bc310c73-d166-49d4-bfc8-de3d792af59f
# ╠═2092b21e-d81b-46c8-82e3-190589ea034d
# ╠═62212f88-9e1b-41a0-b74f-04d814660c71
# ╟─a9151ef1-32b7-42f9-9c99-69aeda6294aa
# ╠═e675ac4f-43ed-4ba2-a70c-d951ef077da6
# ╠═5a198e14-d87b-44e5-b330-ba66b7dd9288
# ╟─8d307ccb-3ad1-4d4d-b56e-aca8583e4a0a
# ╠═ca8a1df6-15f9-46a7-9b46-f2448d54dbc9
# ╠═347af98d-b8a3-484e-8e7b-d7cc9fe989c3
# ╠═6ef36d0e-1195-43f9-b165-93ef22b06b57
# ╠═285ecde5-7cc8-42e8-bee0-efe06003713b
# ╠═333f966c-d6c6-444f-be49-5b14f94c5fcf
# ╠═c52e48fa-e742-4ff4-a5ac-55b344b16375
# ╠═1c80661e-a9df-47aa-899f-5c7eb79a050d
# ╠═d04d45e5-87b2-4f76-b0f8-d9a415608f03
# ╠═c935a6db-ed98-4f01-8e41-b6bd903f7a16
# ╠═d2a9fa6c-9aa5-4818-8746-4fc4142a34ee
# ╠═14634323-48d4-4481-ae6f-602913747220
# ╟─1165c3cb-c90b-4dfb-b7dc-36f3f47b7b65
# ╠═1464378c-e00a-49f5-9a45-771d7e3968e0
# ╠═01a510ae-1d26-4fb1-9203-c0c72c534447
# ╠═e369cc85-f207-4768-8c8e-9e70779656bd
# ╠═ac492a93-4db2-4090-8a85-7b4af63606fd
# ╠═ebcb05bf-1ff6-4dc3-bcc3-ab4dabaa741a
# ╠═0bbf8c5c-468e-495b-88b6-4bd1ec007f97
# ╟─174b80e8-dddb-4f3f-9dbf-19b7ccf7b696
# ╠═c069a4a4-acaf-4611-ad8f-177d82964219
# ╟─30d283b3-c45e-47c6-bbc5-30c908df4779
# ╟─c17cfcb8-01c0-41dd-a6b0-230f1e399cfb
# ╠═24a81d95-8f34-4501-a99e-1f130d39ba12
# ╠═52bde5e2-56e6-42d2-9637-493964e6b398
# ╠═f80212c5-92de-4908-b478-1f4cb7942afd
# ╠═78de9938-04b4-4d7a-b9e7-b3a1f437f1b2
# ╠═12b33efc-f3ad-4af2-ad89-54e471a651c8
# ╟─439457a1-b98f-4802-966a-101bb09fbb33
# ╠═f0ea868f-6a08-49c5-87c4-42931e163d0e
# ╟─58efe369-7f11-4a37-9c99-5f75a28f112a
# ╠═9531e6c5-7249-403c-8fdb-6cf8b95985fe
# ╠═b8124d20-60db-4e7b-ae45-82516c0f7d53
# ╟─59ec6809-e944-4b68-959a-fa5154ed37f7
# ╠═d8d27f57-2355-4a7a-9286-c0cf27c08138
# ╠═a99b82cd-bcc8-47d1-86d2-4526ed396da0
# ╠═3b7d5a9b-6d6d-459c-818d-61dd413970f1
# ╠═efac8b14-0512-492e-a18a-95e2897b89f1
# ╟─ec46e371-4ec7-4fea-969e-1c1306e960b4
# ╠═be8c9830-f61a-4935-ad7d-f17bf3ceefe0
# ╟─180241c8-2d4d-4217-b592-3c630237919a
# ╠═80f2cac1-f9cb-4b7a-a592-d1ef51bb5bb2
# ╟─f6691fe6-dce3-43dd-8fe3-a30d3edbb447
# ╠═91280610-a60f-4fa5-bc46-7f490ac29d6c
# ╟─a4ac1650-2fad-4de0-a4a6-b68842719d7c
# ╠═9dbf3677-fdc3-47d8-b87e-33e314aa0fc3
# ╠═020f91be-3e5d-49ef-8524-ccc91d1b1143
# ╟─6aa86405-31db-4485-bb02-d613e9d5c9d6
# ╟─1acfa505-fa6c-45b9-9d6b-092c762eb94e
# ╟─63beb9af-5763-4db0-a64d-74247d30c3f8
# ╠═cd24a29a-c240-4a4f-97a6-abc99b439b90
# ╠═25648ad4-facb-4181-864d-75241c6c982b
# ╠═cfb50811-f5e2-4dae-8424-db9bcf601ab4
# ╟─84e023b8-0503-4e45-a782-c110fd08bb03
# ╠═81f040bf-d4d1-4997-8303-d9f2f6254404
# ╠═feebbec0-777b-43ca-8252-dbd814c8f84e
# ╠═006db471-9ed1-424f-a43e-66e5dc0a8af9
# ╠═cf5ddd6e-faf3-4338-8c83-bd734b0caa1e
# ╠═6a2a698c-1178-4916-98e4-3d8dd954892e
# ╟─e45480b6-98d9-45c6-a4fa-a22df5142aec
# ╠═c360a3e3-c4c4-42b1-9d78-68c4f7e9abc9
# ╠═9e7ddefe-06f3-4c77-a419-0317b0cfcfb2
# ╠═63ed0f91-5b00-43a6-ba59-09f7b8465cd8
# ╟─4e0dfdd0-010d-4a2d-9f23-4b87f62f42ba
# ╠═26ed158a-8546-4daa-8cfe-a6c7bfcfde57
# ╠═30291f06-b120-46d8-a197-0f2d11153134
# ╟─fab2d08a-b62e-4d83-9a8c-a2d71f246974
# ╠═99f9e29a-b018-474a-aad9-4251b584303c
# ╠═c1257a02-48cd-4c6d-8ce0-5beaab138342
# ╟─d13e75de-2cb5-48bd-966b-2aa8702dec26
# ╠═a254406e-7579-4ec1-9c46-bed389cd046a
# ╠═591cadf3-68e7-4dd4-bd9e-ddae1795fe42
# ╟─4468400e-3f7c-45e7-bbf0-c7100da2810c
# ╠═f3cdd5e9-20ec-417c-9b3e-34f381352fb0
# ╠═fb12053c-e8be-418c-b62a-17934c74f079
# ╠═23814e8e-185b-4550-97c4-f4aa418571d6
# ╠═d4efea27-464e-416c-97cc-58302d5ec829
# ╟─6605a311-2bfb-4ad8-a678-fdbdb826dd32
# ╠═f2d55b58-74a0-408c-b820-962de127c4df
# ╠═a6aed0b2-882c-44bd-96f3-aff42e0062af
# ╠═2ac430a3-8922-4be0-a8ae-a87ec3ad7ff6
# ╠═ece321e3-c1fe-41a9-99e4-168c9420f8ce
# ╠═dd1cf62c-5d88-4769-af81-4d054c8a533c
# ╟─93d584fe-3c2c-4849-ac60-45888767948d
# ╟─75eb6eb7-2b51-43a6-b5bb-4a7068de55b7
# ╟─6b08d896-cdb1-4c3a-bec8-3922eaaac279
# ╠═ddd2a803-07fc-40cc-8db1-e9ffc5748a73
# ╠═559e468f-1970-458b-a9f9-a7fb08291bd1
# ╠═476cb592-cb57-4691-9656-0af55b473b5f
# ╠═420c82bd-eea5-4408-8ec1-0e27ad1d35e4
# ╠═2550e29b-a9bb-4de7-8f5f-7f4c1e0ed55f
# ╠═64b20b98-2733-447f-8d2b-cd3ee32f302c
# ╟─dd079685-283c-4a3b-959b-75200368afb1
# ╠═362e660b-d069-406a-9028-90385f69fedd
# ╠═8afe67c7-a91c-4182-b2d2-8a51ec70e38e
# ╠═1556443c-acbe-47b4-8913-00063c06fe90
# ╠═f653bdfa-ebdd-4e71-92f1-ee905cce6efe
# ╠═6e2ccb33-6eda-4632-9c91-3047235f6817
# ╟─6a78dd1b-af8d-44ff-a51d-c15440752a1d
# ╠═b53c61f8-a52b-4455-b997-0f123a5837ae
# ╟─59598425-3c7b-41de-9533-4575529d15ca
# ╠═a2176faf-e599-4799-8f4d-2fd5160364e2
# ╟─20f2b901-f05d-44c9-a3fb-d49121c59b89
# ╠═65a64e45-a135-4b40-9751-def260671bff
# ╟─43dc8d45-ba68-435a-b613-d7d1370f5e34
# ╠═102f42e8-7973-433f-be87-aefed240441a
# ╠═1accef19-60ac-4ac9-85ad-1f45f8b454ed
# ╠═eb553be0-c7f0-423a-a125-5bfd4e07b13a
# ╠═05802136-7ec1-4468-b82a-3d673436d57e
# ╠═a9e3d8b7-cfbe-4f86-8d15-4ac02e18d203
# ╠═4aa80c7c-c0aa-40ef-ab62-5d4a04a6fda5
# ╠═f4334a01-537a-4720-866f-f4709e656dda
# ╠═3b8619a1-a358-409c-9503-10b0f6270a9c
# ╠═4846a032-c374-4bd5-8426-f67a029522d5
# ╠═d222c0e6-696f-41aa-897a-a0ec4b8fdb68
# ╠═eccf89a9-089f-44f6-9282-2a775205953e
# ╟─6745369d-25ed-432e-95c0-30b648596aaf
# ╟─5f2c5759-768f-4fd5-a8bf-24cdea487f64
# ╟─2270edc1-ef05-4e29-ab46-2093041831b7
# ╟─df89214c-2c73-4842-9893-a87f34a04be1
# ╠═e0bfff4e-6c2e-4032-b447-07bd956da66e
# ╟─98c640aa-72c3-43b0-adf2-183022251ec7
# ╟─08116d16-d041-406c-b41d-8c91b5e68040
# ╟─2e816f20-9d5e-4782-8a06-fa7e1ca9f7c5
# ╠═88531bc9-0cd7-4bdd-a6e8-1487772eb008
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
