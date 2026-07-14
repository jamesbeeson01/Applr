# StatSlice

The stat behind
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md).
Once per layer it resolves a "slice plan" from the model and the plot's
aesthetic mapping (which predictor varies along x, which are pinned by
groups/facets, which are held constant, and how predictions map onto the
y-axis); then, for each group, it generates an `n`-point prediction line
from the model.

## Usage

``` r
StatSlice
```

## Format

An object of class `ggproto`, inheriting from `Stat`.
