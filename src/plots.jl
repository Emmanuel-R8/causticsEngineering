"""
$(SIGNATURES)
"""
function plot_as_quiver(
    g;
    stride = 4,
    scale = 300,
    max_length = 2,
    flipxy = false,
    reversey = false,
    reversex = false,
)

    h, w = size(g)
    xs = Float64[]
    ys = Float64[]
    us = Float64[]
    vs = Float64[]

    for x = 1:stride:w, y = 1:stride:h
        reversex ? push!(xs, x) : push!(xs, -x)
        reversey ? push!(ys, -y) : push!(ys, y)

        p1 = g[y, x]
        u = (g[y, x+1] - g[y, x]) * scale
        v = (g[y+1, x] - g[y, x]) * scale

        u = -u

        reversey && (v = -v)
        reversex && (u = -u)

        # println(u, v)
        u >= 0 ? push!(us, min(u, max_length)) : push!(us, max(u, -max_length))
        v >= 0 ? push!(vs, min(v, max_length)) : push!(vs, max(v, -max_length))
    end

    q =
        flipxy ? quiver(ys, xs, quiver = (vs, us), aspect_ratio = :equal) :
        quiver(xs, ys, quiver = (us, vs), aspect_ratio = :equal)

    display(q)
    readline()
end


"""
$(SIGNATURES)
"""
function plot_velocities_as_quiver(vx, vy; stride = 4, scale = 300, max_length = 2)
    h, w = size(vx)

    xs = Float64[]
    ys = Float64[]
    us = Float64[]
    vs = Float64[]

    for x = 1:stride:w, y = 1:stride:h
        push!(xs, x)
        push!(ys, h - y)

        u = max(vx[x, y], 0.001)
        v = max(vy[x, y], 0.001)

        push!(us, u)
        push!(vs, v)
        # println(u, ": ", v)
    end

    # readline()
    q = quiver(xs, ys, quiver = (us, vs), aspect_ratio = :equal)
    display(q)
    readline()
end



"""
$(SIGNATURES)
"""
function plot_loss!(D, suffix, img)
    println("Loss:")
    println("\tMinimum loss: $(minimum(D))")
    println("\tMaximum loss: $(maximum(D))")

    blue = zeros(size(D))
    blue[D.>0] = D[D.>0]
    red = zeros(size(D))
    red[D.<0] = -D[D.<0]
    green = zeros(size(D))

    rgbImg = RGB.(red, green, blue)'
    save("./examples/loss_$(suffix).png", map(clamp01nan, rgbImg))

    # println("Saving output image:")
    # println(typeof(img))
    # E = Gray.(D)
    # println(typeof(E))
    # outputImg = img - E
    # save("./examples/actual_$(suffix).png", outputImg)
end
