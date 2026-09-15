using Test, CairoMakie

function test_figure()
    fig = Figure()
    lines(fig[1, 1], 0:1, 0:1, axis=(;title="test"))
    fig
end
function test_figure_bytes()
    fname = tempname(suffix=".png")
    save(fname, test_figure())
    bytes = read(fname)
    rm(fname)
    return bytes
end
BYTES_REFERENCE = test_figure_bytes()
using XKCDMakie

@testset "Smoke tests" begin
    bytes_xkcd = test_figure_bytes()        # Figure with XKCD mode

    Makie.update_theme!(fonts=(;bold="bold"))
    bytes_deftitle = test_figure_bytes()    # Title font reset

    Makie.update_theme!(fonts=(;regular="default"))
    bytes_deffonts = test_figure_bytes()    # Ticks font reset

    Makie.set_theme!(theme_xkcd(gridvisible=true, min_dist=Inf,
        noise_generator=XKCDMakie.NOISE_DEFAULT * 0))
    Makie.update_theme!(
        fonts=(;bold="TeX Gyre Heros Makie Bold", regular="TeX Gyre Heros Makie"),
        Axis=(;topspinevisible=true, rightspinevisible=true))
    bytes_nonoise = test_figure_bytes()     # Disable noise & upsampling

    Makie.set_theme!(theme_xkcd(min_dist=15))
    bytes_sparse = test_figure_bytes()      # Sparser path upsampling

    Makie.set_theme!()
    bytes_disabled = test_figure_bytes()    # Reset theme, XKCD disabled

    Makie.set_theme!(theme_xkcd())
    bytes_reenabled = test_figure_bytes()   # Re-enable XKCD mode

    @test bytes_nonoise == BYTES_REFERENCE
    @test bytes_disabled == BYTES_REFERENCE
    @test bytes_reenabled == bytes_xkcd

    # file size (PNG has compression!)
    ref_size = length(BYTES_REFERENCE)
    @test length(bytes_xkcd) > ref_size
    @test length(bytes_deffonts) > ref_size
    @test length(bytes_deftitle) > ref_size
    @test length(bytes_sparse) > ref_size
    @test length(bytes_xkcd) > length(bytes_sparse)

    # title font was NOT default
    @test bytes_xkcd != bytes_deftitle
    # ticks font was not either
    @test bytes_deftitle != bytes_deffonts
end
