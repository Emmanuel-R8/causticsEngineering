# Constants

# Physical parameters

## Materials
const n₁::Float64 = 1.584  # https://pixelandpoly.com/ior.html - polycarbonate
const n₂::Float64 = 1.00  # air
const Δn::Float64 = n₁ - n₂  # Change

## The sides of the block to be carved
const Block_Side::Float64 = 0.15 # meters
## Square block
const Block_Height::Float64 = Block_Side
const Block_Width::Float64 = Block_Side

## Depth parameters. If we imagine a reference place, the top face (facing the caustics) is at
## Top_Offset above it. The flat face facing the light source is Bottom below it.
const Top_Offset::Float64 = 0.01 # 1 centimeters
const Bottom_Offset::Float64 = 0.02 # 2 centimeters

## Optics
const Focal_Length::Float64 = 1.0  # meters

const Caustics_Long_Side::Float64 = 0.20 # m
global Caustics_Height::Float64 = Caustics_Long_Side
global Caustics_Width::Float64 = Caustics_Long_Side

# Caustics picture
global N_Pixel_Side::Int64 = 512
global N_Pixel_Height::Int64 = N_Pixel_Side
global N_Pixel_Width::Int64 = N_Pixel_Side

global Meters_Per_Pixel::Float64 = Caustics_Height / N_Pixel_Height


# calculation
const ω::Float64 = 1.99
# const ω = 2 / (1 + π / sqrt(N_Pixel_Height * N_Pixel_Width))
const N_Iterations_Convergence::Int64 = 10_000        # CHECK: What is a reasonable number of iterations?

# # Global allocations to avoid excessive re-allocations. USEFUL ???
# global container = zeros(Float64, 1_024, 1_024)
# global divergence_intensity = zeros(Float64, 1_024, 1_024)
# global target_map = zeros(Float64, 1_024, 1_024)
