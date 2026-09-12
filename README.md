# XKCDMakie.jl

> Finally, a worthy competitor to Matplotlib's `xkcd` mode

The title speaks for itself: an extremely crude hack into [Makie.jl](https://github.com/MakieOrg/Makie.jl) that makes the plots look more hand-drawn. As of now works only with the CairoMakie backend.

Uses the authentic [xkcd font](https://github.com/ipython/xkcd-font/tree/master).

Paste it into your REPL to install:
```julia
using Pkg; Pkg.add(url="github.com/aryavorskiy/XKCDMakie.jl")
```

Use it the same way you use `CairoMakie`. Should be a drop-in replacement, file an issue if it is not.

## Gallery

All images in this gallery were generated using this package. You can find the code in the [`contrib/`](contrib/) directory.

![Demo](img/demo.png)

**Disclaimer:** these works below belong to Randall Monroe, I only adapted them to XKCDMakie.

| [Stove Ownership](https://xkcd.com/418/) | [Messi](https://xkcd.com/3260/) |
| --- | --- |
| ![Stove ownership (Created by Randall Monroe, adapted to XKCDMakie by Alexander Yavorsky)](img/0418_stove_ownership.png) | ![Messi (Created by Randall Monroe, adapted to XKCDMakie by Alexander Yavorsky)](img/3260_messi.png) |

| [Self-Description](https://xkcd.com/0688/) |
| --- |
| ![Self-Description (Created by Randall Monroe, adapted to XKCDMakie by Alexander Yavorsky)](img/0688_self_description.png) |
