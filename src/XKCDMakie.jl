module XKCDMakie

using CairoMakie, Reexport
@reexport using Makie

randomized_positions(positions) = map(positions) do pt
    pt .+ randn.()
end

function CairoMakie.draw_single(is_lines_plot::Bool, ctx, positions::Vector)
    if is_lines_plot
        return CairoMakie.draw_single_lines(ctx, randomized_positions(positions))
    else
        return CairoMakie.draw_single_segments(ctx, randomized_positions(positions))
    end
end

end # module XKCDMakie
