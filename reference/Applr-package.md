# Applr: Tools for Visualizing and Explaining Linear Models

Applr is a small R package that makes it easy to visualize slices of
higher-dimensional linear models and to present model equations clearly.
It includes base R and ggplot2 helpers, plus an interactive 3D view for
models with two predictors.

## Details

Core capabilities:

- 2D slices of multi-variable models in base graphics

- ggplot2 layer for plotting model slices across facets

- Interactive 3D scatter with fitted surface (two predictors)

- Quick text/LaTeX equations from lm() objects

## Main functions

- autoplot:
  [`autoplot.lm`](https://saundersg.github.io/Applr/reference/autoplot.lm.md)

- Base graphics:
  [`slice_2d`](https://saundersg.github.io/Applr/reference/slice_2d.md),
  [`add_slice_2d`](https://saundersg.github.io/Applr/reference/add_slice_2d.md)

- ggplot2 layer:
  [`geom_slice`](https://saundersg.github.io/Applr/reference/geom_slice.md)
  (built on
  [`StatSlice`](https://saundersg.github.io/Applr/reference/StatSlice.md)
  and
  [`GeomSlice`](https://saundersg.github.io/Applr/reference/GeomSlice.md))

- ggplot2 labeling:
  [`geom_slice_text`](https://saundersg.github.io/Applr/reference/geom_slice_text.md),
  [`geom_slice_subtitle`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md),
  [`geom_slice_caption`](https://saundersg.github.io/Applr/reference/geom_slice_caption.md)

- 3D visualization:
  [`scatter_3d`](https://saundersg.github.io/Applr/reference/scatter_3d.md)

- Equations:
  [`lm_equation`](https://saundersg.github.io/Applr/reference/lm_equation.md),
  [`lm_latex`](https://saundersg.github.io/Applr/reference/lm_latex.md)

- Theme:
  [`theme_lc`](https://saundersg.github.io/Applr/reference/theme_lc.md)

## Quick start

Fit a model and plot a slice:


    library(Applr)
    model <- lm(mpg ~ disp + hp, data = mtcars)
    slice_2d(model, x_axis = "disp")

ggplot2 layer with facets:


    library(ggplot2)
    model <- lm(mpg ~ disp + hp + cyl, data = mtcars)
    ggplot(mtcars, aes(disp, mpg)) +
      geom_point() +
      facet_wrap(~cyl) +
      geom_slice(model = model, predict_vars = list(hp = 110))

## See also

- Function help pages:
  [`?slice_2d`](https://saundersg.github.io/Applr/reference/slice_2d.md),
  [`?geom_slice`](https://saundersg.github.io/Applr/reference/geom_slice.md),
  [`?scatter_3d`](https://saundersg.github.io/Applr/reference/scatter_3d.md),
  [`?lm_equation`](https://saundersg.github.io/Applr/reference/lm_equation.md),
  [`?lm_latex`](https://saundersg.github.io/Applr/reference/lm_latex.md),
  [`?theme_lc`](https://saundersg.github.io/Applr/reference/theme_lc.md)

- The package README for a brief tour

## Author

**Maintainer**: James Beeson <jamesbeeson01@gmail.com>

Authors:

- Cameron McClellan <cameron.m.mcclellan@gmail.com>
