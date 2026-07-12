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

# Recover the model's data and choose the plot's axes: the user's `x_axis` (or
# the first numeric predictor) on x, the raw response on y. Shared by
# autoplot.lm() and slice_explore(), so the two views can never disagree about
# what goes on the axes; `fn` only feeds the message wording.
resolve_autoplot_frame <- function(object, x_axis = NULL, fn = "autoplot") {
  # slice_model_frame() can sometimes recover data-argument-less models from
  # the formula environment, but not reliably (e.g. models fitted inside a
  # function whose local variables are gone) — require the data argument that
  # geom_slice()'s own checks and messages assume.
  if (is.null(object$call$data)) {
    slice_abort(
      what = paste0("The model was fitted without a `data` argument, so ", fn,
                    "() cannot recover its data."),
      hint = "Refit with a data argument, such as 'lm(y ~ x, data = your_data)'."
    )
  }
  model_data <- slice_model_frame(object)

  response_expr <- formula(object)[[2]]
  response_vars <- all.vars(response_expr)
  predictor_vars <- setdiff(all.vars(delete.response(terms(object))), response_vars)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")

  if (length(response_vars) != 1) {
    slice_abort(
      what = paste0("The model's response `", expr_text(response_expr),
                    "` does not use exactly one variable, so ", fn,
                    "() cannot choose a y-axis."),
      hint = "Build the plot yourself with ggplot() + geom_slice()."
    )
  }
  if (length(predictor_vars) == 0) {
    slice_abort(
      what = paste0("The model has no predictors, so ", fn,
                    "() cannot choose an x-axis."),
      hint = "Fit a model with at least one predictor, such as 'lm(y ~ x, data = your_data)'."
    )
  }

  # x-axis: the user's choice, or the first numeric predictor. geom_slice()
  # needs a continuous x-axis, so factor/character predictors are skipped
  # (they are imputed or grouped instead).
  numeric_vars <- predictor_vars[vapply(predictor_vars,
                                        function(v) is.numeric(model_data[[v]]),
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

  list(data = model_data, x_axis = x_axis, response = response_vars,
       predictors = predictor_vars)
}

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
#' Pass `sliders = TRUE` (or name predictors, e.g. `sliders = c(disp, cyl)`)
#' for an interactive [slice_explore()] widget instead: the same plot, with
#' one slider for each predictor the plot does not show, moving the slice in
#' real time. `slider_breaks` and `slider_steps` control the slider grids;
#' see [slice_explore()] for details.
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
#' @param ... Passed on to [geom_slice()] — for example
#'   `predict_vars = list(hp = 110)` to choose the slice,
#'   `interval = "confidence"` for a ribbon, or fixed aesthetics such as
#'   `color = "red"` — or to [scatter_3d()] when `type = "3d"`.
#' @param data A data frame to draw the scatter from instead of the data
#'   recovered from the model — for example the model's data with extra
#'   columns added for `mapping` aesthetics. Passed to [ggplot2::ggplot()].
#'   The rows must still match the data the model was fitted to
#'   ([geom_slice()] checks, and errors on a mismatch).
#' @param mapping Extra aesthetics created with [ggplot2::aes()], passed to
#'   [ggplot2::ggplot()] — for example `mapping = aes(color = factor(cyl))`.
#'   Entries named `x` or `y` override the automatically chosen axes.
#' @param type `"2d"` (default) for a [geom_slice()] ggplot, or `"3d"` for an
#'   interactive [scatter_3d()] surface (needs exactly two numeric predictors).
#' @param x_axis The name of the predictor to place on the x-axis, such as
#'   `x_axis = "disp"`. Defaults to the model's first numeric predictor.
#'   Ignored when `type = "3d"`.
#' @param xaxis Deprecated; use `x_axis` instead.
#' @param sliders If given (and not `FALSE`), return an interactive
#'   [slice_explore()] widget instead of a static ggplot. `TRUE` puts a slider
#'   on every predictor the plot does not show; or name them — bare names
#'   (`sliders = c(disp, cyl)`), strings, or `factor(cyl)` for steps at the
#'   observed values. Cannot be combined with `type = "3d"`.
#' @param slider_breaks,slider_steps Slider grids for `sliders`, passed to
#'   [slice_explore()]: `slider_breaks` gives exact (intentionally jumpy)
#'   step values, `slider_steps` the number of steps in a continuous grid.
#'
#' @returns A ggplot of the model's data with a slice of the model drawn
#'   through it; a plotly surface from [scatter_3d()] when `type = "3d"`; or
#'   an interactive slider widget from [slice_explore()] when `sliders` is
#'   given.
#'
#' @seealso [geom_slice()], which draws the line and handles everything
#'   slice-shaped; [slice_explore()] for the slider view; [scatter_3d()] for
#'   the interactive surface; and [geom_slice_subtitle()] /
#'   [geom_slice_text()] to annotate the result.
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
#' autoplot(lm(mpg ~ disp + hp, data = mtcars), x_axis = "hp")
#'
#' # Transformed response, back-transformed onto the raw mpg axis
#' autoplot(lm(log(mpg) ~ disp, data = mtcars))
#'
#' # Options pass through to geom_slice(); the result is a normal ggplot
#' autoplot(lm(mpg ~ disp + hp, data = mtcars),
#'          predict_vars = list(hp = 110), interval = "confidence") +
#'   labs(title = "Slice at hp = 110")
#'
#' # Custom data and extra aesthetics for the scatter
#' autoplot(lm(mpg ~ disp, data = mtcars),
#'          data = mtcars, mapping = aes(color = factor(cyl)))
#'
#' # An interactive 3-D surface for a two-predictor model
#' if (interactive()) {
#'   autoplot(lm(mpg ~ disp + hp, data = mtcars), type = "3d")
#' }
#'
#' # Interactive sliders for the predictors the plot does not show
#' if (interactive()) {
#'   autoplot(lm(mpg ~ disp + hp + wt, data = mtcars), sliders = TRUE)
#' }
#'
#' @export
autoplot.lm <- function(object, ..., data = NULL, mapping = NULL,
                        type = c("2d", "3d"), x_axis = NULL, xaxis = NULL,
                        sliders = NULL, slider_breaks = NULL,
                        slider_steps = NULL) {
  type <- match.arg(type)
  check_slice_model(object)

  # Capture `sliders` unevaluated before anything can force it: bare variable
  # names (sliders = cyl) must reach slice_explore() as expressions.
  sliders_quo <- rlang::enquo(sliders)
  sliders_given <- !rlang::quo_is_null(sliders_quo)
  if (sliders_given) {
    # sliders = FALSE means the ordinary static plot; evaluate defensively —
    # a bare name like `cyl` may not evaluate at all, which is fine.
    val <- tryCatch(rlang::eval_tidy(sliders_quo), error = function(e) TRUE)
    if (isFALSE(val)) sliders_given <- FALSE
  }

  # The 3-D surface is a wholly different view (a plotly object); hand the model
  # and any surface options straight to scatter_3d() and skip the 2-D plumbing.
  if (type == "3d") {
    if (sliders_given) {
      slice_abort(
        what = "`sliders` cannot be combined with type = \"3d\".",
        hint = "Drop 'type = \"3d\"' to get the slider view, or 'sliders =' for the 3-D surface."
      )
    }
    return(scatter_3d(object, ...))
  }

  x_axis <- resolve_deprecated_xaxis(x_axis, xaxis, "autoplot")

  # The slider view is a plotly widget built by slice_explore(); it shares
  # this method's data recovery, axis choice, and geom_slice() plumbing.
  if (sliders_given) {
    return(slice_explore(object, sliders = sliders_quo,
                         slider_breaks = slider_breaks,
                         slider_steps = slider_steps, ...,
                         mapping = mapping, data = data, x_axis = x_axis))
  }

  frame <- resolve_autoplot_frame(object, x_axis, fn = "autoplot")

  if (!is.null(data) && !is.data.frame(data)) {
    slice_abort(
      what = "`data` must be a data frame.",
      hint = "Pass the data to plot the scatter from, such as 'data = your_data'."
    )
  }
  if (!is.null(mapping) && !inherits(mapping, "uneval")) {
    slice_abort(
      what = "`mapping` must be created by aes().",
      hint = "For example, 'mapping = aes(color = cyl)'."
    )
  }

  # Bare symbols (not .data[[...]]) so geom_slice() can read which model
  # variables are on the axes from the plot's aesthetic mapping. User-supplied
  # aes() entries override the auto-chosen ones (e.g. mapping = aes(x = hp)
  # replaces the default x); anything else (color, shape, ...) is added.
  plot_mapping <- aes(x = !!as.name(frame$x_axis), y = !!as.name(frame$response))
  if (!is.null(mapping)) {
    plot_mapping[names(mapping)] <- mapping
  }

  ggplot(if (is.null(data)) frame$data else data, plot_mapping) +
    geom_point() +
    geom_slice(object, ...) +
    geom_slice_subtitle()
}
