#' Applr: Tools for Visualizing and Explaining Linear Models
#'
#' Applr is a small R package that makes it easy to visualize slices of
#' higher-dimensional linear models and to present model equations clearly.
#' It includes base R and ggplot2 helpers, plus an interactive 3D view for
#' models with two predictors.
#'
#' Core capabilities:
#' - 2D slices of multi-variable models in base graphics
#' - ggplot2 layer for plotting model slices across facets
#' - Interactive 3D scatter with fitted surface (two predictors)
#' - Quick text/LaTeX equations from lm() objects
#'
#' @section Main functions:
#' - Base graphics: \code{\link{slice_2d}}, \code{\link{add_slice_2d}}, \code{\link{drawit}}
#' - ggplot2 layer: \code{\link{geom_slice}} (built on \code{\link{StatSlice}} and \code{\link{GeomSlice}})
#' - 3D visualization: \code{\link{scatter_3d}}
#' - Equations: \code{\link{lm_equation}}, \code{\link{lm_latex}}
#' - Theme: \code{\link{theme_lc}}
#'
#' @section Quick start:
#' Fit a model and plot a slice:
#' \preformatted{
#' library(Applr)
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' slice_2d(model, xaxis = "disp")
#' }
#'
#' ggplot2 layer with facets:
#' \preformatted{
#' library(ggplot2)
#' model <- lm(mpg ~ disp + hp + cyl, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   facet_wrap(~cyl) +
#'   geom_slice(model = model, predict_vars = list(hp = 110))
#' }
#'
#' @seealso \itemize{
#'   \item Function help pages: \code{?slice_2d}, \code{?geom_slice}, \code{?scatter_3d}, \code{?lm_equation}, \code{?lm_latex}, \code{?theme_lc}
#'   \item The package README for a brief tour
#' }
#'
#' @docType package
#' @name Applr
#' @aliases Applr-package Applr
#'
#' @import ggplot2
#' @import tidyr
#' @import plotly
#' @import rlang
#' @import graphics
#' @import stats
NULL
