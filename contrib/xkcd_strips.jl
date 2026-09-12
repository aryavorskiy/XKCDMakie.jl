# %% Stove Ownership
fig = Figure(size=(400, 300))
ys = ones(100)
ys[71:end] .-= range(0, 1, length=30)
ax, _ = lines(fig[1, 1], ys, axis=(xlabel="time", ylabel="my overall health",
    title="Stove Ownership by Randall Monroe", limits=(nothing, (-0.1, 1.5)),
        topspinevisible=false, rightspinevisible=false))
hidedecorations!(ax, label=false)
annotation!(ax, (-100, -75), (71, 1),
    text=uppercase("The day I realised\nI can cook bacon\nwhenever I wanted"),
    style = Ann.Styles.LineArrow())
fig
