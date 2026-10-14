using Test, CairoMakie

function test_figure()
    fig = Figure()
    linesegments(fig[1, 1], 0:3, 0:3, axis=(;title="test"), color=0:3)
    Label(fig[0, 1], L"x^2 + y^2 = z^2")
    fig
end
function test_figure_bytes()
    fname = tempname() * ".png"
    save(fname, test_figure())
    bytes = read(fname)
    rm(fname)
    return bytes
end
BYTES_REFERENCE = test_figure_bytes()
using XKCDMakie

@testset "Smoke tests" begin
    bytes_xkcd = test_figure_bytes()        # Figure with XKCD mode

    Makie.update_theme!(fonts=(;bold="TeX Gyre Heros Makie Bold"))
    bytes_deftitle = test_figure_bytes()    # Title font reset

    Makie.update_theme!(fonts=(;regular="default"))
    bytes_deffonts = test_figure_bytes()    # Ticks font reset

    Makie.set_theme!(theme_xkcd(gridvisible=true, min_dist=Inf,
        noise_generator=XKCDMakie.NOISE_DEFAULT * 0),
        fonts=(;bold="TeX Gyre Heros Makie Bold", regular="default"),
        Axis=(;topspinevisible=true, rightspinevisible=true))
    XKCDMakie.config_latex!(text=false)
    bytes_nonoise = test_figure_bytes()     # Disable noise & upsampling

    Makie.set_theme!(theme_xkcd(min_dist=15))
    bytes_sparse = test_figure_bytes()      # Sparser path upsampling

    Makie.set_theme!()
    bytes_disabled = test_figure_bytes()    # Reset theme, XKCD disabled

    Makie.set_theme!(theme_xkcd())
    bytes_reenabled_p = test_figure_bytes() # Re-enable XKCD mode

    XKCDMakie.config_latex!()
    bytes_reenabled = test_figure_bytes()   # Restore default Latex mode

    XKCDMakie.config_latex!(math=true)
    bytes_latex_all = test_figure_bytes()

    XKCDMakie.config_latex!(text=false)
    bytes_latex_none = test_figure_bytes()

    XKCDMakie.config_latex!()
    bytes_latex_default = test_figure_bytes()

    @test bytes_nonoise == BYTES_REFERENCE
    @test bytes_disabled == BYTES_REFERENCE
    @test bytes_reenabled == bytes_xkcd
    @test bytes_reenabled_p == bytes_latex_none

    # file size (PNG has compression!)
    ref_size = length(BYTES_REFERENCE)
    @test length(bytes_xkcd) > ref_size
    @test length(bytes_deffonts) > ref_size
    @test length(bytes_deftitle) > ref_size
    @test length(bytes_sparse) > ref_size
    @test length(bytes_reenabled_p) > length(bytes_sparse)

    # title font was NOT default
    @test bytes_xkcd != bytes_deftitle
    # ticks font was not either
    @test bytes_deftitle != bytes_deffonts

    # Changing math settings changed things
    @test bytes_latex_all != BYTES_REFERENCE
    @test bytes_latex_none != BYTES_REFERENCE
    @test bytes_latex_all != bytes_latex_none
    @test bytes_latex_default == bytes_xkcd
end
