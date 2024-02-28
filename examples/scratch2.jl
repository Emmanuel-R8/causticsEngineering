# Work in a temporary environment
using Pkg
Pkg.activate(; temp = true)

# Speed up by avoiding updating the repository when adding packages
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
Pkg.develop(path = "$(@__DIR__)/..")

# Add useful package
Pkg.add(["Revise", "Images"])

using Revise, Images
using CausticsEngineering

Pkg.add(["VoronoiCells", "GeometryBasics", "Plots", "Random", "ImageMagick"])

using Random

using VoronoiCells
using GeometryBasics
using Plots


# The meshes start with MESH_LENGTH x MESH_LENGTH points
MESH_LENGTH = 16

# First create a mesh where all the points are regularly spaced.
regular_points = reshape(
    [
        GeometryBasics.Point2(-0.05 + i / MESH_LENGTH, -0.05 + j / MESH_LENGTH) for
        i = 1:MESH_LENGTH, j = 1:MESH_LENGTH
    ],
    :,
)
regular_tess = voronoicells(
    regular_points,
    Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(1, 1)),
)

begin
    scatter(regular_points, markersize = 2, label = "generators")
    annotate!([
        (regular_points[n][1] + 0.02, regular_points[n][2] + 0.03, Plots.text(n)) for
        n = 1:MESH_LENGTH
    ])
    plot!(regular_tess, legend = :topleft)
end



img = load("examples/einstein.jpg")
img = Gray.(img)

# Array of pixels irradiance. Matrix is transposed to have x, y coordinates (more natural)
imgf32 = Float32.(img)'
x_max, y_max = size(imgf32)
irr_per_point = sum(imgf32) / MESH_LENGTH^2

centroids = reshape(
    [
        GeometryBasics.Point2(
            (-0.05 + i / MESH_LENGTH) * x_max,
            (-0.05 + j / MESH_LENGTH) * y_max,
        ) for i = 1:MESH_LENGTH, j = 1:MESH_LENGTH
    ],
    :,
)
tess = voronoicells(
    centroids,
    Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(x_max, y_max)),
)

# For each cell, being a polygon
for _ = 1:10
    new_centroids = []
    for c ∈ tess.Cells
        cell_irradiance = Float64[]
        x_average = Float64[]
        y_average = Float64[]

        # For each triangle
        # i = 2
        for i = 1:length(c)-2
            tri_irradiance = 0.0
            tri_x_average = 0.0
            tri_y_average = 0.0
            tri_irradiance = 0.0

            p1, p2, p3 = c[i], c[i+1], c[i+2]

            # Find top point (lowest y) and assigns to p1
            if p1.data[2] > p2.data[2]
                p1, p2 = p2, p1
            end
            if p1.data[2] > p3.data[2]
                p1, p3 = p3, p1
            end

            # Find bottom point (highest y) and assigns to p3
            if p2.data[2] > p3.data[2]
                p2, p3 = p3, p2
            end

            # Scan from the top to the middle point
            n_total_lines = p3.data[2] - p1.data[2]
            n_top_lines = p2.data[2] - p1.data[2]
            n_bottom_lines = p3.data[2] - p2.data[2]

            # Change in x per line along each triangle side
            Δ_12 = n_top_lines > 0 ? (p2.data[1] - p1.data[1]) / n_top_lines : 0.0
            Δ_23 = n_bottom_lines > 0 ? (p3.data[1] - p2.data[1]) / n_bottom_lines : 0.0
            Δ_13 = n_total_lines > 0 ? (p3.data[1] - p1.data[1]) / n_total_lines : 0.0

            for y = 0:n_top_lines
                y_current = clamp(floor(Int, p1.data[2] + y), 1, y_max)

                x_beg = clamp(floor(Int, p1.data[1] + Δ_12 * y), 1, x_max)
                x_end = clamp(floor(Int, p1.data[1] + Δ_13 * y), 1, x_max)

                for x = x_beg:x_end
                    pixel = imgf32[x, y_current]

                    tri_irradiance += pixel
                    tri_x_average += x * pixel
                    tri_y_average += y_current * pixel
                end
            end

            # Scan from the middle point to the bottom point
            for y = 1:n_bottom_lines
                y_current = clamp(floor(Int, p1.data[2] + y), 1, y_max)

                x_beg = clamp(floor(Int, p2.data[1] + Δ_23 * y), 1, x_max)
                x_end = clamp(floor(Int, p1.data[1] + Δ_13 * y), 1, x_max)

                for x = x_beg:x_end
                    pixel = imgf32[x, y_current]

                    tri_irradiance += pixel
                    tri_x_average += x * pixel
                    tri_y_average += y_current * pixel
                end
            end

            tri_irradiance = tri_irradiance == 0.0 ? 1e-10 : tri_irradiance
            push!(cell_irradiance, tri_irradiance)
            push!(x_average, tri_x_average / tri_irradiance)
            push!(y_average, tri_y_average / tri_irradiance)
        end

        new_x = cell_irradiance' * x_average / sum(cell_irradiance)
        new_y = cell_irradiance' * y_average / sum(cell_irradiance)
        push!(new_centroids, GeometryBasics.Point2(new_x, new_y))
    end

    centroids = [c for c ∈ new_centroids]
    tess = voronoicells(
        centroids,
        Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(x_max, y_max)),
    )
end

begin
    scatter(centroids, markersize = 2, label = "")
    # annotate!([(regular_points[n][1] + 0.02, regular_points[n][2] + 0.03, Plots.text(n)) for n in 1:MESH_LENGTH])
    plot!(tess, legend = :topleft)
end
#



function image_to_tesselation(filename::String; mesh_length = MESH_LENGTH)
    # Load an image and converts to gray scale
    img = Gray.(Images.load(filename))

    # Initial equally spaced centroids
    tess = reshape(
        [
            GeometryBasics.Point2(-0.05 + i / MESH_LENGTH, -0.05 + j / MESH_LENGTH) for
            i = 1:MESH_LENGTH, j = 1:MESH_LENGTH
        ],
        :,
    )


end





# The next mesh has all points randomly positioned.
rng = Random.MersenneTwister(1337)
points = [Point2(rand(rng), rand(rng)) for _ = 1:MESH_LENGTH^2]
tess = voronoicells(points, Rectangle(Point2(0, 0), Point2(1, 1)));


begin
    scatter(points, markersize = 2, label = "generators")
    annotate!([(points[n][1] + 0.02, points[n][2] + 0.03, Plots.text(n)) for n = 1:10])
    plot!(tess, legend = :topleft)
end
