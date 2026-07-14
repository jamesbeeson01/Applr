# StatSliceText

The stat behind
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md).
It resolves the same slice spec as
[StatSlice](https://saundersg.github.io/Applr/reference/StatSlice.md)
(borrowed from the plot's
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
layer), reduces each prediction line to its endpoint, and attaches the
label text.

## Usage

``` r
StatSliceText
```

## Format

An object of class `ggproto`, inheriting from `Stat`.
