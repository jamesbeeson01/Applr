# GeomSliceText

The geom behind
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md):
[ggplot2::GeomText](https://ggplot2.tidyverse.org/reference/Geom.html)
whose labels are displaced by a fixed number of points at draw time
(like axis tick label margins), so the gap between line end and label is
constant regardless of label text, axis range, or plot size.

## Usage

``` r
GeomSliceText
```

## Format

An object of class `ggproto`, inheriting from `GeomText`.
