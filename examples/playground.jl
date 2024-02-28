# Work in a temporary environment
using Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
Pkg.activate(; temp=true)

# Add useful packages
Pkg.add(["Revise", "Debugger"])
using Revise, Debugger


###################################################################################################
##
## ACTUAL START
##

Pkg.add(["Gridap", "CairoMakie", "Images", "Plots"])

using Images

@__DIR__
image = Images.load(joinpath(@__DIR__, "cat_posing.jpg")) # Check current working directory with pwd()

imageBW = Float64.(Gray.(image));
imageBW = imageBW ./ sum(imageBW);
imageW, imageH = size(imageBW)

# image as a function from [0, 1] x [0, 1] -> [0, 1]
img(x) = imageBW[floor(x[1] * imageW), floor(x[2] * imageH)]


using Gridap

save_path = joinpath(@__DIR__, "playground_model")

# Number of point on subgrid
n = 50
domain = (0, 1, 0, 1)
partition = (n, n)

model = CartesianDiscreteModel(domain, partition)
degree = 2
Ω = Triangulation(model)
dΩ = Measure(Ω, degree)

writevtk(model, save_path)


order = 1
ref_fe = ReferenceFE(lagrangian, Float64, order)
V0 = TestFESpace(model, ref_fe; conformity=:H1)


neumanntags = ["circle", "triangle", "square"]
Γ = BoundaryTriangulation(model, tags=neumanntags)
dΓ = Measure(Γ, degree)

f(x) = 1.0
h(x) = 3.0

a(u, v) = ∫(∇(v) ⋅ ∇(u)) * dΩ
b(v) = ∫(v * f) * dΩ + ∫(v * h) * dΓ



import CairoMakie as Mke


###################################################################################################
##
## EXAMPLE WITH MESHES
##

# https://juliageometry.github.io/MeshesDocs/stable/index.html

Pkg.add(["Meshes", "PlyIO"])

using Meshes, PlyIO

# 2D points
A = Point(0.0, 1.0) # double precision as expected
B = Point(0.0f0, 1.0f0) # single precision as expected
C = Point(0, 0) # Integer is converted to Float64 by design
D = Point2(0, 1) # explicitly ask for double precision
E = Point2f(0, 1) # explicitly ask for single precision

# 3D points
F = Point(1.0, 2.0, 3.0) # double precision as expected
G = Point(1.0f0, 2.0f0, 3.0f0) # single precision as expected
H = Point(1, 2, 3) # Integer is converted to Float64 by design
I = Point3(1, 2, 3) # explicitly ask for double precision
J = Point3f(1, 2, 3) # explicitly ask for single precision

for P in (A, B, C, D, E, F, G, H, I, J)
    println("Coordinate type: ", coordtype(P))
    println("Embedding dimension: ", embeddim(P))
end



b = Box((0.0, 0.0, 0.0), (1.0, 1.0, 1.0))
viz(b)

s = Sphere((0.0, 0.0, 0.0), 1.0)
viz(s)

vs = sample(s, RegularSampling(200)); # 10 points over the sphere
viz(collect(vs))



mesh = discretize(s, RegularDiscretization(10, 10))
ref = refine(mesh, TriRefinement())

fig = Mke.Figure(size=(800, 400))
viz(fig[1, 1], mesh, showfacets=true)
viz(fig[1, 2], ref, showfacets=true)
fig



using PlyIO

# helper function to read *.ply files
function readply(fname)
    ply = load_ply(fname)
    x = ply["vertex"]["x"]
    y = ply["vertex"]["y"]
    z = ply["vertex"]["z"]
    points = Point3.(x, y, z)
    connec = [connect(Tuple(c .+ 1)) for c in ply["face"]["vertex_indices"]]
    SimpleMesh(points, connec)
end

# download mesh from the web
file = download(
    "https://raw.githubusercontent.com/juliohm/JuliaCon2021/master/data/beethoven.ply",
)

# read mesh from disk
mesh = readply(file)

# smooth mesh with 30 iterations
smesh = mesh |> TaubinSmoothing(30)

fig = Mke.Figure(size=(1000, 500))
viz(fig[1, 1], mesh)
viz(fig[1, 2], smesh)
fig
