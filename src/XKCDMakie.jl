module XKCDMakie

using Reexport
@reexport using CairoMakie
import Makie: Colorant
import CairoMakie: Cairo, Screen
import FreeTypeAbstraction, MathTeXEngine

using CoherentNoise
const NOISE_DEFAULT =
    scale(opensimplex2_2d(seed=rand(UInt64)), 3e0) * 0.2 +
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e1) * 0.4 +
    scale(opensimplex2_2d(seed=rand(UInt64)), 1e2) * 0.8

const XKCD_FONT_DIR = joinpath(@__DIR__, "..", "fonts")

"""
    theme_xkcd([; gridvisible, noise_generator, min_dist])

Sets the theme for XKCD-style rendering

## Keyword arguments
- `gridvisible`: visibility of the grid (default: false)
- `min_dist`: accuracy of hand-drawn line emulation. Lower is more precise, but heavier to compute (default: 3)
- `noise_generator`: the noise sampler that is responsible for hand-drawn line emulation.
"""
theme_xkcd(;gridvisible=false, noise_generator=NOISE_DEFAULT, min_dist=3) = Theme(;
    xkcd_enabled = true,
    patchstrokecolor = :black,
    patchstrokewidth = 1,
    Axis = (
        topspinevisible=false,
        rightspinevisible=false,
        xgridvisible=gridvisible,
        ygridvisible=gridvisible
    ),
    fonts = (
        bold = "XKCD",
        regular = "XKCD",
        italic = "XKCD",
        bold_italic = "XKCD"
    ),
    noise_generator, min_dist
)
export theme_xkcd
theme_get(key, default) = if key in keys(Makie.current_default_theme())
    Makie.current_default_theme()[key][]
else
    default
end
function normalize_path(positions, interps::Tuple; min_dist=theme_get(:min_dist, 3))
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

function interleave_pairs(vals, fillwith=nothing)
    out_vals = similar(vals, 3, length(vals) ÷ 2)
    out_vals[1:2, :] .= reshape(vals, 2, :)
    @views if fillwith === nothing
        out_vals[3, :] .= out_vals[2, :]
    else
        fill!(out_vals[3, :], fillwith)
    end
    return vec(out_vals)
end
function line_segments_to_lines(positions, interps::Tuple=())
    interleaved_positions = interleave_pairs(positions, Point2f(NaN, NaN))
    if interps isa Tuple{}
        return interleaved_positions
    else
        return interleaved_positions, map(interps) do interp
            interp isa AbstractVector && length(interp) == length(positions) ?
            interleave_pairs(interp) : interp
        end
    end
end

function jumble!(positions)
    noise = theme_get(:noise_generator, NOISE_DEFAULT)
    map!(positions, positions) do pt
        any(isnan, pt) && return pt
        pt .+ (sample(noise, pt...), sample(noise, (pt .+ (3234, 1230))...))
    end
end

# Hacking into CairoMakie's internals for line draws...
function CairoMakie.draw_single(islines::Bool, ctx, positions::Vector)
    if !islines
        positions = line_segments_to_lines(positions)
    end
    theme_get(:xkcd_enabled, false) ||
        return CairoMakie.draw_single_lines(ctx, positions)
    new_pos = jumble!(normalize_path(positions))
    return CairoMakie.draw_single_lines(ctx, new_pos)
end
function CairoMakie.draw_multi(islines::Bool, ctx, positions::Vector, colors, linewidths, dash)
    if !islines
        positions, (colors, linewidths) = line_segments_to_lines(positions, (colors, linewidths))
    end
    theme_get(:xkcd_enabled, false) ||
        return CairoMakie.draw_multi_lines(ctx, positions, colors, linewidths, dash)
    new_pos, (new_colors, new_lw) = normalize_path(positions, (colors, linewidths))
    jumble!(new_pos)
    return CairoMakie.draw_multi_lines(ctx, new_pos, new_colors, new_lw, dash)
end

# And polygon draws
function CairoMakie.draw_poly(scene::Scene, screen::Screen, poly::Poly, points::Vector{<:Point2}, color::Union{Colorant, Cairo.CairoPattern},
        _args...)
    CairoMakie.draw_poly_as_mesh(scene::Scene, screen::Screen, poly)
end
function CairoMakie.draw_poly(scene::Scene, screen::Screen, poly::Poly, _)
    CairoMakie.draw_poly_as_mesh(scene, screen, poly)
end

enable_math!() = MathTeXEngine.set_texfont_family!(MathTeXEngine.FontFamily("XKCD"))
disable_math!() = MathTeXEngine.set_texfont_family!()

function __init__()
    Makie.set_theme!(theme_xkcd())
    if XKCD_FONT_DIR ∉ FreeTypeAbstraction.fontpaths()
        push!(FreeTypeAbstraction.fontpaths(), XKCD_FONT_DIR)
    end
    xkcd_fontpath = joinpath(XKCD_FONT_DIR, "xkcd-script.otf")
    MathTeXEngine.default_font_families["XKCD"] = MathTeXEngine.FontFamily(
        Dict(
            :regular => xkcd_fontpath,
            :italic => xkcd_fontpath,
            :bold => xkcd_fontpath,
            :bolditalic => xkcd_fontpath,
            :math => xkcd_fontpath
        )
    )
end
end # module XKCDMakie
