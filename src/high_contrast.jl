#
# In this file, we implement the algo described in the paper:
# "High-Contrast Computational Caustic Design" found at
# [Paper](https://www.researchgate.net/profile/Yuliy-Schwartzburg/publication/269391149_High-contrast_Computational_Caustic_Design/links/54e5da350cf2cd2e028b3669/High-contrast-Computational-Caustic-Design.pdf)
#
# Abstract:
#       We present a new algorithm for computational caustic design. Our
#       algorithm solves for the shape of a transparent object such that the
#       refracted light paints a desired caustic image on a receiver screen.
#       We introduce an optimal transport formulation to establish a
#       correspondence between the input geometry and the unknown target shape.
#       A subsequent 3D optimization based on an adaptive discretization scheme
#       then finds the target surface from the correspondence map. Our approach
#       supports piecewise smooth surfaces and non-bijective mappings, which
#       eliminates a number of shortcomings of previous methods. This leads to
#       a significantly richer space of caustic images, including smooth
#       transitions, singularities of infinite light density, and completely
#       black areas. We demonstrate the effectiveness of our approach with
#       several simulated and fabricated examples.

using VoronoiCells
using GeometryBasics
using Plots
using Random


# The meshes start with MESH_LENGTH x MESH_LENGTH points
const MESH_LENGTH = 16
const UNIT_RECT = Rectangle(Point2(0, 0), Point2(1, 1))

# First create a mesh where all the points are regularly spaced.
regular_points = reshape([Point2(-0.05 + i / MESH_LENGTH, -0.05 + j / MESH_LENGTH) for i in 1:MESH_LENGTH, j in 1:MESH_LENGTH], :)
regular_tesselation = voronoicells(regular_points, UNIT_RECT)

function plot_tess(points, resselation)
    p = scatter(points, markersize=2, label="generators")
    annotate!(p, [(points[n][1] + 0.02, points[n][2] + 0.03, Plots.text(n)) for n in 1:length(points)])
    return plot!(tesselation, legend=:topleft)
end



"""
    high_contrast_caustics(source, otm)

High-level loop described in section 5 - Target Optimization

src: vertex positions of source map
otm: optimal transport map

returns vertex positions of target map
"""
function high_contrast_caustics(source, otm)

    vertex = source
    target_position = otm_interpolation(vertex, otm)

    not_converged = false
    while not_converged
        d = normalize(target_position - vertex)
        n = fresnel_mapping(source, d)
        vertex = normal_integration(x, n)
    end

    return vertex
end


"""
    otm_interpolation(source, otm)

Optimal Transport Map optimization described in section 5 - Target Optimization

v1: vertex 1
otm: optimal transport map

returns vertex
"""
function otm_interpolation(source, otm)
    return []
end


"""
    normalize(vertex)

Normalize the vertex

vertex:

returns vertex
"""
function normalize(vertex)
    return
end


"""
    fresnel_mapping(vertex, d)
"""
function fresnel_mapping(vertex, d)
    return
end


"""
    normal_integration(vertex, n)
"""
function normal_integration(vertex, n)
    return
end
