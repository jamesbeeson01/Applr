# autoplot.lm() — a complete ggplot from a fitted lm() in one call.
#
# The method builds the scatter of the model's own data with a geom_slice()
# line through it, so everything slice-shaped (imputation of invisible
# predictors, back-transformation of a transformed response, intervals via
# `...`) is geom_slice()'s job; autoplot.lm() only has to recover the data
# and choose the axes. The method must be registered (S3method(autoplot, lm)
# in NAMESPACE, via the roxygen @export below) or autoplot(model) falls
# through to ggplot2's autoplot.default — the feasts/ggtime packages register
# theirs the same way.

# Re-export the generic so autoplot(model) works with only Applr attached.
#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

#' Automatically plot a linear model
#'
#' `autoplot()` turns a fitted [lm()] into a complete ggplot in one call: the
#' data the model was fitted to as a scatter, with a [geom_slice()] prediction
#' line through it. The result is a regular ggplot, so it can be extended with
#' `+` as usual (labels, scales, more layers).
#'
#' Pass `type = "3d"` for a model with exactly two numeric predictors to get an
#' interactive [scatter_3d()] surface instead of the 2-D slice; `...` is then
#' forwarded to [scatter_3d()] (e.g. `n`, `colors`).
#'
#' The model's *first numeric* predictor goes on the x-axis (override with
#' `mapping = aes(x = ...)`) and the raw response variable goes on the y-axis.
#' Everything else
#' is handled by [geom_slice()] and reported on the console: predictors not
#' visible on the plot are imputed (mean for numeric, most common value for
#' factor/character), and a transformed response such as `lm(log(y) ~ x)` is
#' automatically back-transformed to match the raw y-axis.
#'
#' @param object A linear model fitted by [lm()] **with a `data` argument** —
#'   the data is recovered from the model, so `lm(y ~ x, data = your_data)`
#'   works but `lm(your_data$y ~ your_data$x)` does not.
#' @param mapping Aesthetics created with [ggplot2::aes()], passed to
#'   [ggplot2::ggplot()] — for example `mapping = aes(color = factor(cyl))`.
#'   They resolve against the model's full data frame, so a column the model
#'   never mentions (such as `cyl` above) still works. An entry named `x`
#'   chooses the x-axis (`mapping = aes(x = hp)`), overriding the default first
#'   numeric predictor; an entry named `y` overrides the response axis.
#' @param type `"2d"` (default) for a [geom_slice()] ggplot, or `"3d"` for an
#'   interactive [scatter_3d()] surface (needs exactly two numeric predictors).
#' @param summary Whether to print `summary(object)` to the console before
#'   returning the plot (default `TRUE`). Printing it up front means you can
#'   refit the model and inspect its coefficients from inside the same
#'   `autoplot()` call; pass `summary = FALSE` to suppress it.
#' @param xaxis Deprecated; use `mapping = aes(x = your_predictor)` instead.
#' @param ... Passed on to [geom_slice()] — for example
#'   `predict_vars = list(hp = 110)` to choose the slice,
#'   `interval = "confidence"` for a ribbon, or fixed aesthetics such as
#'   `color = "red"` — or to [scatter_3d()] when `type = "3d"`.
#'
#' @returns A ggplot of the model's data with a slice of the model drawn
#'   through it, or — when `type = "3d"` — a plotly surface from [scatter_3d()].
#'
#' @seealso [geom_slice()], which draws the line and handles everything
#'   slice-shaped; [scatter_3d()] for the interactive surface; and
#'   [geom_slice_subtitle()] / [geom_slice_text()] to annotate the result.
#'
#' @examples
#' library(ggplot2)
#'
#' # A complete plot from a model in one call
#' autoplot(lm(mpg ~ disp, data = mtcars))
#'
#' # Predictors not on the plot are imputed (a message says how)
#' autoplot(lm(mpg ~ disp + hp, data = mtcars))
#'
#' # Choose which predictor goes on the x-axis
#' autoplot(lm(mpg ~ disp + hp, data = mtcars), mapping = aes(x = hp))
#'
#' # Transformed response, back-transformed onto the raw mpg axis
#' autoplot(lm(log(mpg) ~ disp, data = mtcars))
#'
#' # Options pass through to geom_slice(); the result is a normal ggplot
#' autoplot(lm(mpg ~ disp + hp, data = mtcars),
#'          predict_vars = list(hp = 110), interval = "confidence") +
#'   labs(title = "Slice at hp = 110")
#'
#' # Extra aesthetics for the scatter (mapping goes to ggplot())
#' autoplot(lm(mpg ~ hp + factor(cyl), data = mtcars),
#'          mapping = aes(color = factor(cyl)))
#'
#' # An interactive 3-D surface for a two-predictor model
#' if (interactive()) {
#'   autoplot(lm(mpg ~ disp + hp, data = mtcars), type = "3d")
#' }
#'
#' @export
autoplot.lm <- function(object, mapping = NULL, type = c("2d", "3d"),
                        summary = TRUE, xaxis = NULL, ...) {
  type <- match.arg(type)
  check_slice_model(object)

  # Print the model summary up front (before the plot) so you can refit and
  # read the coefficients from the same autoplot() call. It goes to the console
  # first so the returned plot's output isn't buried underneath it.
  if (isTRUE(summary)) {
    print(summary(object))
  }

  # The 3-D surface is a wholly different view (a plotly object); hand the model
  # and any surface options straight to scatter_3d() and skip the 2-D plumbing.
  if (type == "3d") {
    return(scatter_3d(object, ...))
  }

  if (!is.null(mapping) && !inherits(mapping, "uneval")) {
    slice_abort(
      what = "`mapping` must be created by aes().",
      hint = "For example, 'mapping = aes(color = cyl)'."
    )
  }

  # The x-axis is now chosen through the mapping (aes(x = ...)), so the
  # deprecated scalar `xaxis` just seeds that aesthetic — erroring if the
  # mapping already sets x, since the two would then disagree.
  if (!is.null(xaxis)) {
    slice_warn(
      what = "The `xaxis` argument of `autoplot()` is deprecated.",
      hint = "Use `mapping = aes(x = your_predictor)` instead."
    )
    if (!is.character(xaxis) || length(xaxis) != 1 || is.na(xaxis)) {
      slice_abort(
        what = "`xaxis` must be a single variable name.",
        hint = "For example, 'mapping = aes(x = hp)'."
      )
    }
    if (!is.null(mapping) && "x" %in% names(mapping)) {
      slice_abort(
        what = "The x-axis is set by both `xaxis` and `mapping = aes(x = ...)`.",
        hint = "Drop the deprecated `xaxis` and keep 'mapping = aes(x = ...)'."
      )
    }
    if (is.null(mapping)) mapping <- aes()
    mapping$x <- aes(x = !!as.name(xaxis))$x
  }

  # slice_model_frame() can sometimes recover data-argument-less models from
  # the formula environment, but not reliably (e.g. models fitted inside a
  # function whose local variables are gone) — require the data argument that
  # geom_slice()'s own checks and messages assume.
  if (is.null(object$call$data)) {
    slice_abort(
      what = "The model was fitted without a `data` argument, so autoplot() cannot recover its data.",
      hint = "Refit model with a data argument, such as 'lm(y ~ x, data = your_data)'."
    )
  }
  # Plot the model's *whole* data frame, not just the formula variables, so a
  # mapping can reference any column the data carries — e.g. aes(color = cyl)
  # for a model that never mentions cyl. geom_slice() still reads the model,
  # not this frame, for its predictions.
  model_data <- tryCatch(
    as.data.frame(eval(object$call$data, environment(formula(object)))),
    error = function(e) slice_model_frame(object)
  )

  response_expr <- formula(object)[[2]]
  response_vars <- all.vars(response_expr)
  predictor_vars <- setdiff(all.vars(delete.response(terms(object))), response_vars)

  if (length(response_vars) != 1) {
    slice_abort(
      what = paste0("The model's response `", expr_text(response_expr),
                    "` does not use exactly one variable, so autoplot() cannot choose a y-axis."),
      hint = "Build the plot yourself with ggplot() + geom_slice()."
    )
  }
  if (length(predictor_vars) == 0) {
    slice_abort(
      what = "The model has no predictors, so autoplot() cannot choose an x-axis.",
      hint = "Fit a model with at least one predictor, such as 'lm(y ~ x, data = your_data)'."
    )
  }

  # Bare symbols (not .data[[...]]) so geom_slice() can read which model
  # variables are on the axes from the plot's aesthetic mapping. The mapping's
  # own entries (x, color, shape, ...) are layered on top of the y default.
  plot_mapping <- aes(y = !!as.name(response_vars))

  # x-axis: taken from the mapping if it sets one (aes(x = ...)); otherwise the
  # first numeric predictor. geom_slice() needs a continuous x-axis, so
  # factor/character predictors are skipped (imputed or grouped instead).
  if (is.null(mapping) || !"x" %in% names(mapping)) {
    numeric_vars <- predictor_vars[vapply(predictor_vars,
                                          function(v) is.numeric(model_data[[v]]),
                                          logical(1))]
    if (length(numeric_vars) == 0) {
      slice_abort(
        what = "None of the model's predictors are numeric, but geom_slice() needs a continuous x-axis.",
        hint = "Fit a model with at least one numeric predictor, or set one with 'mapping = aes(x = ...)'."
      )
    }
    x_axis <- numeric_vars[1]
    if (!identical(x_axis, predictor_vars[1])) {
      slice_inform(
        what = paste0("The first predictor `", predictor_vars[1],
                      "` is not numeric - used `", x_axis, "` for the x-axis."),
        hint = paste0("To choose the x-axis, use 'mapping = aes(x = ", x_axis, ")'.")
      )
    }
    plot_mapping$x <- aes(x = !!as.name(x_axis))$x
  }

  if (!is.null(mapping)) {
    plot_mapping[names(mapping)] <- mapping
  }

  ggplot(model_data, plot_mapping) +
    geom_point() +
    geom_slice(object, ...) +
    geom_slice_subtitle()
}
