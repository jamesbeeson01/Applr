# Courtesy stubs for removed functions. Each errors with a pointer to its
# replacement so old student code fails with directions, not confusion.
# Drop the stub (and its export) after a release or two.

#' Defunct: use geom_slice() instead
#'
#' `geom_fit()` was removed in favor of [geom_slice()], which does everything
#' it did (prediction lines from a fitted `lm()`, confidence/prediction
#' ribbons, back-transformation) plus grouping, faceting, and held-variable
#' reporting. Calling it is an error that points to the replacement.
#'
#' @param ... Ignored; accepted only so old calls reach the error message.
#'
#' @seealso [geom_slice()]
#' @keywords internal
#' @export
geom_fit <- function(...) {
  slice_abort(
    what = "`geom_fit()` has been removed; use `geom_slice()` instead.",
    hint = paste0("It takes the model the same way, such as 'geom_slice(model)'. ",
                  "For a ribbon use 'interval = \"confidence\"'; ",
                  "instead of 'new_data' use 'predict_vars = list(hp = 110)'.")
  )
}

#' Deprecated: use slice_2d() instead
#'
#' `drawit()` drew a single base-R slice of an `lm()` and required the caller
#' to name a value for every other predictor. That job is now done by
#' [slice_2d()], which imputes unspecified predictors (mean for numeric, most
#' common level for factors) instead of demanding them. `drawit()` is kept as a
#' deprecated shim: it warns and forwards to [slice_2d()], mapping `xaxis` to
#' `x_axis` and passing graphical parameters (`col`, `lty`, ...) straight
#' through. It will be removed in a future release.
#'
#' @param model A linear model fit with [stats::lm()].
#' @param xaxis The primary explanatory variable to vary along the x-axis.
#' @param ... Graphical parameters forwarded to [slice_2d()] (e.g. `col`, `lty`).
#'
#' @return A 2D base-R plot of a model slice (called for its side effect).
#'
#' @seealso [slice_2d()]
#' @keywords internal
#' @export
drawit <- function(model, xaxis, ...) {
  slice_warn(
    what = "`drawit()` is deprecated; use `slice_2d()` instead.",
    hint = paste0("Call it as 'slice_2d(model, x_axis = \"",
                  if (missing(xaxis)) "wt" else xaxis,
                  "\")'. Unlike `drawit()`, `slice_2d()` imputes any ",
                  "predictors you do not name rather than requiring them.")
  )
  slice_2d(model, x_axis = if (missing(xaxis)) NULL else xaxis, ...)
}
