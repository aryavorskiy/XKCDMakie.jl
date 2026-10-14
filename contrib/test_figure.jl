using XKCDMakie
XKCDMakie.enable_math!()

fig = Figure(size=(600, 500))
Label(fig[0, 1:2], "XKCDMakie.jl demo plot", fontsize=20, font=:bold)

xs = 0:0.1:10
lines(fig[1, 1], xs, sin.(xs), axis=(;title="Line plots"), linestyle=:dash)
lines!(fig[1, 1], xs, -sin.(xs), color=xs)

hist(fig[1, 2], randn(1000), normalization=:pdf,
    axis=(;limits=((-5, 5), (0, nothing)), title="Histograms and annotations"))
n_pdf(x) = 1/sqrt(2pi) * exp(-x^2/2)
annotation!(fig[1, 2], 3.5, n_pdf(0) / 2, 3, n_pdf(3), text="3 sigma\n limit",
    path=Ann.Paths.Arc(-0.4), style=Ann.Styles.LineArrow(), labelspace=:data)

xs = LinRange(0, 2pi, 15)
ys = LinRange(0, 3pi, 10)
us = [sin(x) * cos(y) for x in xs, y in ys]
vs = [-cos(x) * sin(y) for x in xs, y in ys]
strength = vec(sqrt.(us .^ 2 .+ vs .^ 2))
arrow_fun(x) = Point2f(sin(x[1])*cos(x[2]), -cos(x[1])*sin(x[2]))
arrows2d(fig[2, 1:2], xs, ys, arrow_fun, lengthscale=0.3, color=strength,
        axis=(;title="And even arrow plots!"))
textlabel!(fig[2, 1:2], Point2f(pi, 1.5pi), L"Math also kinda supported: $\sum_i \frac{1}{n^2} = \frac{\pi^2}{6}$")
save("demo.png", fig)
