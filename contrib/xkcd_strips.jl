using XKCDMakie, FileIO

# %% Stove Ownership
fig = Figure(size=(400, 300))
ys = ones(100)
ys[71:end] .-= range(0, 1, length=30)
ax, _ = lines(fig[1, 1], ys, axis=(xlabel="time", ylabel="my overall health",
    title="Stove Ownership by Randall Monroe", limits=(nothing, (-0.1, 1.5))))
hidedecorations!(ax, label=false)
annotation!(ax, (-100, -75), (71, 1),
    text=uppercase("The day I realised\nI can cook bacon\nwhenever I wanted"),
    style = Ann.Styles.LineArrow())
fig
save("0418_stove_ownership.png", fig)

# %% Messi
fig = Figure(size=(400, 300))
yrs = 2006:4:2026
goals = [0.3, 0, 0.6, 0.2, 1, 3]
Box(fig[1, 1], color=:transparent, alignmode=Inside())
ax = Axis(fig[1, 1], xticks=(2006:2027, fill("", 22)), xtickalign=1, yticks=0:3,
    title="LIONEL MESSI\nworld cup goals per game", alignmode=Outside(10))
scatterlines!(ax, yrs, goals)
annotation!(ax, yrs, goals, text=string.(yrs))
lines!(2006..2027, x -> 0.02 * exp((x-2006) / 4), linestyle=:dash)
Label(fig[2, 1], uppercase("At this rate, by 2040 Messi will be\nscoring hundreds of goals per game"), tellwidth=false)
save("3260_messi.png", fig)

# %% Self-description
fig = Figure(size=(800, 200))
ax, _ = pie(fig[1, 1], [88, 12], color=[:white, :black], offset=-1.9, axis=(;alignmode=Outside(10),
    aspect=DataAspect(), limits=(-2.7, 1.2, -1.4, 1.4)))
annotation!(ax, -1.9, 0.8, -0.66, 0.66, text=uppercase("Fraction of\nthis image\nwhich is white"),
    labelspace = :data, fontsize=10, path = Ann.Paths.Arc(0.4))
annotation!(ax, -1.9, -0.8, -0.66, -0.66, text=uppercase("Fraction of\nthis image\nwhich is black"),
    labelspace = :data, fontsize=10, path = Ann.Paths.Arc(-0.4))
hidedecorations!(ax)
hidespines!(ax)
Box(fig[1, 1], color=:transparent, alignmode=Inside())

ax2 = Axis(fig[1, 2], alignmode=Outside(10), xticks=1:3, yticks=Int[],
    height=Relative(0.75), width=Relative(0.8), valign=-0.1)
hidexdecorations!(ticklabels=false)
barplot!(ax2, [3, 4, 2], color=:black, gap=0.7)
ylims!(ax2, 0, nothing)
Label(fig[1, 2], uppercase("Amount of\nblack ink\nby panel:"), height=Relative(0.3), width=Relative(0.3),
    halign=0.05, valign=1, tellheight=false, tellwidth=false, fontsize=10)
Box(fig[1, 2], color=:transparent, alignmode=Inside())

if isfile("0688_self_description.png")
    ax3 = Axis(fig[1, 3], xticks=[0], yticks=[0], alignmode=Outside(10), height=Relative(0.65),
        valign=:bottom, xticklabelsize=8, yticklabelsize=8, aspect=DataAspect())
    image!(ax3, rotr90(load("0688_self_description.png")))
end
Label(fig[1, 3], uppercase("Location of\nblack ink in\nthis image:"), height=Relative(0.3), width=Relative(0.3),
    halign=0.05, valign=1, tellheight=false, tellwidth=false, fontsize=10)
Box(fig[1, 3], color=:transparent, alignmode=Inside())
save("0688_self_description.png", fig)
