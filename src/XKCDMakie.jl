module XKCDMakie

@reexport using CairoMakie
import Makie: Colorant, Polygon
import CairoMakie: Cairo, Screen

using CoherentNoise, Base.ScopedValues
const NOISE = ScopedValue(
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e1) * 0.3 +
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e2) * 0.7
)

function normalize_path(positions, interps::Tuple; min_dist=2)
    pt1 = first(positions)
    out = [pt1]
    interp_mappers = map(interps) do interp
        interp isa Vector ? [first(interp)] : interp, interp
    end
    for i in 2:length(positions)
        pt2 = positions[i]
        d2 = sum(abs2, pt1 - pt2)
        if isnan(d2) || d2 < min_dist^2
            push!(out, pt2)
            foreach(interp_mappers) do arg
                out_interp, interp = arg
                out_interp isa Vector &&
                    push!(out_interp, interp[i])
            end
        else
            n = ceil(Int, sqrt(d2) / min_dist)
            for j in 1:n
                push!(out, pt1 + (pt2 - pt1) * j/n)
            end
            foreach(interp_mappers) do arg
                out_interp, interp = arg
                if out_interp isa Vector
                    for _ in 1:n
                        push!(out_interp, interp[i])
                    end
                end
            end
        end
        pt1 = pt2
    end
    return out, map(first, interp_mappers)
end
normalize_path(positions; kw...) = normalize_path(positions, (); kw...)[1]

function line_segments_to_lines(positions)
    out_pts = similar(positions, 3, length(positions) ÷ 2)
    out_pts[1:2, :] .= reshape(positions, 2, :)
    out_pts[3, :] .= Ref(Point2f(NaN, NaN))
    return vec(out_pts)
end

jumble!(positions) = map!(positions) do pt
    any(isnan, pt) && return pt
    pt .+ (sample(NOISE[], pt...), sample(NOISE[], (pt .+ (3234, 1230))...))
end

# Hacking into CairoMakie's internals for line draws...
function CairoMakie.draw_single(is_lines_plot::Bool, ctx, positions::Vector)
    if !is_lines_plot
        positions = line_segments_to_lines(positions)
    end
    new_pos = jumble!(normalize_path(positions))
    return CairoMakie.draw_single_lines(ctx, new_pos)
end

function CairoMakie.draw_multi(islines::Bool, ctx, positions::Vector, colors, linewidths, dash)
    if !islines
        positions = line_segments_to_lines(positions)
    end
    new_pos, (new_colors, new_lw) = normalize_path(positions, (colors, linewidths))
    jumble!(new_pos)
    return CairoMakie.draw_multi_lines(ctx, new_pos, new_colors, new_lw, dash)
end

# And polygon draws
function CairoMakie.draw_poly(scene::Scene, screen::Screen, poly::Poly, points::Vector{<:Point2}, color::Union{Colorant, Cairo.CairoPattern},
        args...)
    CairoMakie.draw_poly_as_mesh(scene::Scene, screen::Screen, poly)
end
function draw_poly(scene::Scene, screen::Screen, poly::Poly, _)
    CairoMakie.draw_poly_as_mesh(scene, screen, poly)
end
function draw_poly(scene::Scene, screen::Screen, poly, polygons::AbstractArray{<:Polygon})
    CairoMakie.draw_poly_as_mesh(scene, screen, poly)
end

end # module XKCDMakie
