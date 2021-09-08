using Revise, Debugger

using Images
image = Images.load("./examples/cat_posing.jpg"); # Check current working directory with pwd()

using CausticsEngineering
mesh, imageBW = engineer_caustics(image);


Gray.(imageBW)

mesh.pixel.r[1:10, 1:10]
mesh.pixel.c[1:10, 1:10]
mesh.pixel.ϕ[1:10, 1:10]
mesh.pixel.vr[1:10, 1:10]
mesh.pixel.vc[1:10, 1:10]

mesh.toptriangles[1:10]
mesh.bottriangles[1:10]

mesh.pixel.r[250:260, 250:260]
mesh.pixel.c[250:260, 250:260]
mesh.pixel.ϕ[250:260, 250:260]


using Test

t3 = (
    CausticsEngineering.Vertex3D(5.0, 5.0, 0.01, 0.1, -2.0),
    CausticsEngineering.Vertex3D(6.0, 5.0, 0.01, 0.1, 2.0),
    CausticsEngineering.Vertex3D(5.5, 5.5, 0.01, 0.5, -3.0),
)

CausticsEngineering.find_maximum_t(t3)


typeof(CartesianIndex(3, 5)[1])

t = Matrix{Tuple{CartesianIndex(2),CartesianIndex(2),CartesianIndex(2)}}(undef, 2, 2)

t[1, 1] = (CartesianIndex(1, 1), CartesianIndex(2, 1), CartesianIndex(1, 2))
typeof((CartesianIndex(1, 1), CartesianIndex(2, 1), CartesianIndex(1, 2)))


f.toptriangles[CartesianIndex(5, 5)]

f = FaceMesh(5, 5);
v3 = CausticsEngineering.top_triangle3D(f, CartesianIndex(5, 5))
CausticsEngineering.find_maximum_t(v3)

v3 = CausticsEngineering.top_triangle3D(f, CartesianIndex(5, 5))
CausticsEngineering.area(v3...)

v3 = CausticsEngineering.bot_triangle3D(f, CartesianIndex(5, 5))
CausticsEngineering.area(v3...)

CausticsEngineering.get_pixel_area(f)

for _ = 1:100
    h = rand(Float64, (10, 10))
    d = rand(Float64, (10, 10))
    print(CausticsEngineering.relax(h, d))
end

c = t[1]

f.pixel(c)

t = CausticsEngineering.top_triangle3D(f, CartesianIndex(1, 1))



# Indexing structs
struct TT
    a::Int
    b::Int
end

using StructArrays


aa = StructArrays()

aa[:].a = 0
