module XKCDMakie

using Reexport
@reexport using CairoMakie
using Pkg.Artifacts
import Makie: Colorant, Polygon, ComputeGraph
import CairoMakie: Cairo, Screen

artifact_toml = joinpath(@__DIR__, "Artifacts.toml")
xkcd_font_hash = artifact_hash("xkcd-font", artifact_toml)
if xkcd_font_hash === nothing || !artifact_exists(xkcd_font_hash)
    xkcd_font_hash = create_artifact() do artifact_dir
        xkcd_font_repo = "https://github.com/ipython/xkcd-font/raw/refs/heads/master"
        download("$xkcd_font_repo/xkcd-script/font/xkcd-script.otf", joinpath(artifact_dir, "xkcd-script.otf"))
        download("$xkcd_font_repo/xkcd/build/xkcd-Regular.otf", joinpath(artifact_dir, "xkcd-regular.otf"))
        download("$xkcd_font_repo/xkcd/build/xkcd.otf", joinpath(artifact_dir, "xkcd.otf"))
    end
    bind_artifact!(artifact_toml, "xkcd-font", xkcd_font_hash)
end

xkcd_font_dir = artifact_path(xkcd_font_hash)

theme_xkcd() = Theme(
    patchstrokecolor = :black,
    patchstrokewidth = 1,
    fonts = (
        bold = joinpath(xkcd_font_dir, "xkcd-script.otf"),
        regular = joinpath(xkcd_font_dir, "xkcd-regular.otf")
    )
)
export theme_xkcd

using CoherentNoise, Base.ScopedValues
const NOISE = ScopedValue(
    scale(opensimplex2_2d(seed=rand(UInt64)), 3e0) * 0.2 +
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e1) * 0.4 +
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e2) * 0.8
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
function CairoMakie.draw_poly(scene::Scene, screen::Screen, poly::Poly, _)
    CairoMakie.draw_poly_as_mesh(scene, screen, poly)
end

function __init__()
    Makie.set_theme!(theme_xkcd())
end
end # module XKCDMakie
