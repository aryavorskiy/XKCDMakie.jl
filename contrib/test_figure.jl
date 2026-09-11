using XKCDMakie

fig = Figure()
lines(fig[1, 1], 0:0.1:10, sin.(0:0.1:10))
fig
