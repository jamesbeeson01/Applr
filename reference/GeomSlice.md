# GeomSlice

The geom behind
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md):
[ggplot2::GeomSmooth](https://ggplot2.tidyverse.org/reference/Geom.html)
with slice-flavored default aesthetics. Like
[`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html),
it draws a line plus — when the stat supplies `ymin`/`ymax` (i.e.
`interval = "confidence"` or `"prediction"`) — a ribbon; `alpha` styles
the ribbon, not the line.

## Usage

``` r
GeomSlice
```

## Format

An object of class `ggproto`, inheriting from `GeomSmooth`.
