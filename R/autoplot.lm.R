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
#' data the model was fitted to as a scatter, a [geom_slice()] prediction line
#' through it. The result is a regular ggplot, so it
#' can be extended with `+` as usual (labels, scales, more layers).
#'
#' The model's *first numeric* predictor goes on the x-axis (override with
#' `x_axis`) and the raw response variable goes on the y-axis. Everything else
#' is handled by [geom_slice()] and reported on the console: predictors not
#' visible on the plot are imputed (mean for numeric, most common value for
#' factor/character), and a transformed response such as `lm(log(y) ~ x)` is
#' automatically back-transformed to match the raw y-axis.
#'
#' @param object A linear model fitted by [lm()] **with a `data` argument** —
#'   the data is recovered from the model, so `lm(y ~ x, data = your_data)`
#'   works but `lm(your_data$y ~ your_data$x)` does not.
#' @param ... Passed on to [geom_slice()]: for example
#'   `predict_vars = list(hp = 110)` to choose the slice,
#'   `interval = "confidence"` for a ribbon, or fixed aesthetics such as
#'   `color = "red"`.
#' @param x_axis The name of the predictor to place on the x-axis, such as
#'   `x_axis = "disp"`. Defaults to the model's first numeric predictor.
#' @param xaxis Deprecated; use `x_axis` instead.
#'
#' @returns A ggplot of the model's data with a slice of the model drawn
#'   through it.
#'
#' @examples
#' \dontrun{
#' autoplot(lm(mpg ~ disp, data = mtcars))
#'
#' # Invisible predictors are imputed (a message says how)
#' autoplot(lm(mpg ~ disp + hp, data = mtcars))
#'
#' # Transformed response, back-transformed onto the raw mpg axis
#' autoplot(lm(log(mpg) ~ disp, data = mtcars))
#'
#' # Options pass through to geom_slice(); the result is a normal ggplot
#' autoplot(lm(mpg ~ disp + hp, data = mtcars),
#'          predict_vars = list(hp = 110), interval = "confidence") +
#'   labs(title = "Slice at hp = 110")
#' }
#'
#' @export
autoplot.lm <- function(object, ..., x_axis = NULL, xaxis = NULL) {
  x_axis <- resolve_deprecated_xaxis(x_axis, xaxis, "autoplot")
  check_slice_model(object)

  # slice_model_frame() can sometimes recover data-argument-less models from
  # the formula environment, but not reliably (e.g. models fitted inside a
  # function whose local variables are gone) — require the data argument that
  # geom_slice()'s own checks and messages assume.
  if (is.null(object$call$data)) {
    slice_abort(
      what = "The model was fitted without a `data` argument, so autoplot() cannot recover its data.",
      hint = "Refit with a data argument, such as 'lm(y ~ x, data = your_data)'."
    )
  }
  data <- slice_model_frame(object)

  response_expr <- formula(object)[[2]]
  response_vars <- all.vars(response_expr)
  predictor_vars <- setdiff(all.vars(delete.response(terms(object))), response_vars)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")

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

  # x-axis: the user's choice, or the first numeric predictor. geom_slice()
  # needs a continuous x-axis, so factor/character predictors are skipped
  # (they are imputed or grouped instead).
  numeric_vars <- predictor_vars[vapply(predictor_vars,
                                        function(v) is.numeric(data[[v]]),
                                        logical(1))]
  if (!is.null(x_axis)) {
    if (!is.character(x_axis) || length(x_axis) != 1 || is.na(x_axis)) {
      slice_abort(
        what = "`x_axis` must be a single variable name.",
        hint = paste0("For example, 'x_axis = \"", predictor_vars[1], "\"'.")
      )
    }
    if (!x_axis %in% predictor_vars) {
      slice_abort(
        what = paste0("`x_axis` variable \"", x_axis, "\" not found in the model."),
        hint = paste0("The model's predictors are ", backticked(predictor_vars), ".")
      )
    }
    if (!x_axis %in% numeric_vars) {
      slice_abort(
        what = paste0("`x_axis` variable `", x_axis,
                      "` is not numeric, but geom_slice() needs a continuous x-axis."),
        hint = if (length(numeric_vars) > 0) {
          paste0("Use a numeric predictor: ", backticked(numeric_vars), ".")
        }
      )
    }
  } else {
    if (length(numeric_vars) == 0) {
      slice_abort(
        what = "None of the model's predictors are numeric, but geom_slice() needs a continuous x-axis.",
        hint = "Fit a model with at least one numeric predictor."
      )
    }
    x_axis <- numeric_vars[1]
    if (!identical(x_axis, predictor_vars[1])) {
      slice_inform(
        what = paste0("The first predictor `", predictor_vars[1],
                      "` is not numeric - used `", x_axis, "` for the x-axis."),
        hint = paste0("To choose the x-axis, use 'x_axis = \"", x_axis, "\"'.")
      )
    }
  }

  # Bare symbols (not .data[[...]]) so geom_slice() can read which model
  # variables are on the axes from the plot's aesthetic mapping.
  ggplot(data, aes(x = !!as.name(x_axis), y = !!as.name(response_vars))) +
    geom_point() +
    geom_slice(object, ...)
}
