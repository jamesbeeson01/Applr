# slice_2d() / add_slice_2d() — draw a 2D slice of a fitted lm() in base R.
#
# Both functions share prepare_slice_data(), which resolves the slice (which
# predictor varies along x, which are held constant and at what values),
# predicts along it, and back-transforms predictions onto the y-axis. The
# validation helpers (check_slice_model(), check_back_transform(),
# check_slice_interval()) are shared with geom_slice() and live in
# R/geom_slice.R.


#' 2D Slicer
#'
#' Take a linear model and display a 2D slice in base R. This function creates
#' a new plot comparing the response y variable with one predictor x variable
#' and displaying a linear model line with all other predictor variables
#' held at constant values. For unspecified variables, the x_axis is assumed
#' to be the first predictor in the model and all other variable are imputed
#' (mean for numeric, first level for factors).
#'
#' @param model A linear model
#' @param x_axis A non-required specification of the x-axis variable; default
#'   is the first x var in the lm. May also be an expression of the model's
#'   predictors, such as `x_axis = "x * x_pos"`, in which case predictions are
#'   made at the model's own data points and placed at the expression's value.
#' @param n Number of displayed points; default is 100
#' @param caption Boolean to include caption with values of predictor variables not shown in the chart, TRUE by default
#' @param back_transform How to map predictions onto the y-axis when the
#'   model's response is transformed. Default `TRUE` auto-detects from the
#'   model formula; `FALSE` turns back-transformation off; a one-argument
#'   function (e.g. `exp`) or a name (`"log"`, `"log10"`, `"log2"`, `"sqrt"`,
#'   `"exp"`, `"inverse"`) applies that transformation.
#' @param interval Draw a shaded band around the line: `"none"` (default), or
#'   `"confidence"` / `"prediction"` for the corresponding [predict.lm()]
#'   interval.
#' @param ... Remaining vars (color, linetype, etc.)
#' @param xaxis Deprecated; use `x_axis` instead.
#'
#' @returns A 2D graph of a sliced model
#'
#' @importFrom grDevices adjustcolor
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ disp, data = mtcars)
#' slice_2d(model, x_axis = 'disp')
#'
#' # With a 95% confidence band around the line
#' slice_2d(model, x_axis = 'disp', interval = "confidence")
#' }
#'
#' @export
slice_2d <- function(model, x_axis = NULL, n = 100, caption = TRUE,
                     back_transform = TRUE, interval = "none", ..., xaxis = NULL) {
  x_axis <- resolve_deprecated_xaxis(x_axis, xaxis, "slice_2d")
  model_expr <- substitute(model)
  model_name <- if (is.symbol(model_expr)) as.character(model_expr) else "model"

  # Prepare data (dots are passed as a list so a held variable named `x`
  # cannot partially match the `x_axis` formal)
  prep <- prepare_slice_data(model = model, x_axis = x_axis, n = n,
                             back_transform = back_transform,
                             interval = interval, dots = list(...),
                             model_name = model_name, fn = "slice_2d")

  # PLOT

  # With an interval band, the y range must cover the band, not just the data
  ylim <- NULL
  if (!is.null(prep$line$lwr)) {
    ylim <- range(prep$y_obs, prep$line$lwr, prep$line$upr, na.rm = TRUE)
  }

  # Create the base plot with original data points
  plot(prep$y_obs ~ prep$x_obs,
       xlab = prep$x_label,
       ylab = prep$y_name,
       main = deparse(formula(model)),
       pch = 19,
       col = "steelblue",
       ylim = ylim)

  # Add the interval band (if any) and the prediction line
  draw_slice_line(prep$line, prep$plot_args)

  # Add a caption with predictor values that aren't visible in the plot
  # While this is functional to some extent, it has a clear complex problem,
  # which is detailed at the bottom of the file.
  if (caption) {
    # Add the caption to the plot
    mtext(prep$caption_text, # text
          side = 3, # Top margin
          line = 0.5, # Just under the title (line 0.5)
          adj = 0, # Left-align
          # cex = 0.8, # Smaller text size
          col = "gray40")
  }
}


#' 2D Slice to R Plot
#'
#' Take a slice from a linear model and add the displayed graph to a preexisting R plot.
#' This function is similar to slice_2d() but adds a line to an existing plot rather
#' than creating a new one. Useful for overlaying multiple model slices or adding
#' model predictions to scatter plots.
#'
#' @param model A linear model
#' @param x_axis A non-required specification of the x-axis variable; default
#'   is the first x var in the lm. May also be an expression of the model's
#'   predictors, such as `x_axis = "x * x_pos"`, in which case predictions are
#'   made at the model's own data points and placed at the expression's value.
#' @param n Number of displayed points; default is 100
#' @param caption Boolean to include caption with values of predictor variables not shown in the chart, FALSE by default
#' @param back_transform How to map predictions onto the y-axis when the
#'   model's response is transformed. Default `TRUE` auto-detects from the
#'   model formula; `FALSE` turns back-transformation off; a one-argument
#'   function (e.g. `exp`) or a name (`"log"`, `"log10"`, `"log2"`, `"sqrt"`,
#'   `"exp"`, `"inverse"`) applies that transformation.
#' @param interval Draw a shaded band around the line: `"none"` (default), or
#'   `"confidence"` / `"prediction"` for the corresponding [predict.lm()]
#'   interval.
#' @param ... Remaining vars (color, linetype, etc.)
#' @param xaxis Deprecated; use `x_axis` instead.
#'
#' @returns A line added to a preexisting R plot displaying a 2D graphable slice of an HD model
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' plot(mpg ~ disp, data = mtcars)
#' add_slice_2d(model,x_axis='disp', hp=100)
#' }
#'
#' @export
add_slice_2d <- function(model, x_axis = NA, n = 100, caption = FALSE,
                         back_transform = TRUE, interval = "none", ..., xaxis = NULL) {
  x_axis <- resolve_deprecated_xaxis(x_axis, xaxis, "add_slice_2d")
  model_expr <- substitute(model)
  model_name <- if (is.symbol(model_expr)) as.character(model_expr) else "model"

  # Prepare data (dots are passed as a list so a held variable named `x`
  # cannot partially match the `x_axis` formal)
  prep <- prepare_slice_data(model = model, x_axis = x_axis, n = n,
                             back_transform = back_transform,
                             interval = interval, dots = list(...),
                             model_name = model_name, fn = "add_slice_2d")

  # Warn if the slice is outside the current plot window
  usr <- try(par("usr"), silent = TRUE)
  if (!inherits(usr, "try-error") && is.numeric(usr)) {
    xlim <- usr[1:2]; ylim <- usr[3:4]
    xr <- range(prep$line$x, na.rm = TRUE)
    yr <- range(prep$line$fit, prep$line$lwr, prep$line$upr, na.rm = TRUE)
    if (xr[2] < xlim[1] || xr[1] > xlim[2] || yr[2] < ylim[1] || yr[1] > ylim[2]) {
      slice_warn(
        what = "Slice is outside the current plot range; the line may not be visible or aligned."
      )
    }
  }

  # Add the interval band (if any) and the prediction line to the existing
  # plot. This assumes a plot already exists - it will error if none is active.
  draw_slice_line(prep$line, prep$plot_args)

  # Add a caption with predictor values that aren't visible in the plot
  if (caption) {
    # Add the caption to the plot
    mtext(prep$caption_text, # text
          side = 3, # Top margin
          line = 0.5, # Just under the title (line 0.5)
          adj = 0, # Left-align
          # cex = 0.8, # Smaller text size
          col = "gray40")
  }
}


# Draw one prepared slice onto the active plot: the interval band first (when
# the line has lwr/upr columns), then the prediction line on top. The band
# takes a translucent version of the line's color so custom-colored slices
# get matching bands.
draw_slice_line <- function(line, plot_args) {
  if (!is.null(line$lwr)) {
    line_col <- if (!is.null(plot_args$col)) plot_args$col else par("col")
    polygon(c(line$x, rev(line$x)), c(line$lwr, rev(line$upr)),
            col = adjustcolor(line_col, alpha.f = 0.2), border = NA)
  }
  # do.call used for lines function to allow a list "plot_args" in place of ...
  do.call(lines, c(list(x = line$x, y = line$fit), plot_args))
}


# Error if the data the model's call points to has changed since the model
# was fitted (e.g. the data frame was mutated after lm()). A slice through a
# stale model drawn over the new data is meaningless, but looks plausible.
# Only *positive* mismatches abort: when the fitted frame was not kept
# (lm(..., model = FALSE)), the model used a subset, or the frame cannot be
# rebuilt, later stages give more specific errors.
check_slice_fit_data <- function(model, orig_data, model_name = "model") {
  fitted_frame <- model$model
  if (is.null(fitted_frame) || !is.null(model$call$subset)) return(invisible())
  current <- tryCatch(model.frame(formula(model), data = orig_data),
                      error = function(e) NULL)
  if (is.null(current)) return(invisible())

  column_equal <- function(a, b) {
    if (is.numeric(a) && is.numeric(b)) {
      isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE))
    } else {
      identical(as.character(a), as.character(b))
    }
  }
  shared <- intersect(names(fitted_frame), names(current))
  same <- nrow(current) == nrow(fitted_frame) &&
    all(vapply(shared, function(v) column_equal(fitted_frame[[v]], current[[v]]),
               logical(1)))
  if (!same) {
    slice_abort(
      what = paste0("The data being plotted is not the data `", model_name,
                    "` was fitted to."),
      hint = paste0("The data changed after the model was fitted; refit it, ",
                    "such as '", model_name, " <- lm(y ~ x, data = your_data)'.")
    )
  }
  invisible()
}


# This data preparation is shared by both slice_2d and add_slice_2d.
# `dots` is list(...) from the caller: held-variable values plus any base
# plotting arguments for lines().
prepare_slice_data <- function(model, x_axis, n, back_transform, interval,
                               dots, model_name = "model", fn = "slice_2d") {
  # Validate the model and the simple arguments (helpers shared with
  # geom_slice; back_transform becomes NULL (auto), FALSE, or a function)
  check_slice_model(model, fn = fn)
  interval <- check_slice_interval(interval)
  back_transform <- check_back_transform(back_transform)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    slice_abort(
      what = "`n` must be a single number of at least 2.",
      hint = "For example, 'n = 100'."
    )
  }

  # Get original variable names
  response_vars <- all.vars(formula(model)[[2]])
  y_name <- response_vars[1]
  predictor_vars <- setdiff(all.vars(delete.response(terms(model))), response_vars)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")

  # Determine x_axis if not specified
  if (is.null(x_axis) || (length(x_axis) == 1 && is.na(x_axis))) {
    x_axis <- predictor_vars[1]
    slice_inform(
      what = "X-axis not specified - Used first x variable as x-axis",
      hint = paste0("To specify, use 'x_axis = \"var_name\"' such as 'x_axis = \"",
                    x_axis, "\"'")
    )
  }
  if (!is.character(x_axis) || length(x_axis) != 1) {
    slice_abort(
      what = "`x_axis` must be the name of one model predictor, as a string.",
      hint = paste0("For example, 'x_axis = \"", predictor_vars[1], "\"'.")
    )
  }

  # The x-axis is either one predictor (simple mode) or an expression of
  # predictors such as "x * x_pos" (composite mode)
  x_expr <- tryCatch(str2lang(x_axis), error = function(e) NULL)
  x_vars <- if (is.null(x_expr)) character(0) else all.vars(x_expr)
  x_simple <- !is.null(x_expr) && is.name(x_expr)
  if (is.null(x_expr) || length(x_vars) == 0 || !all(x_vars %in% predictor_vars)) {
    slice_abort(
      what = paste0("`x_axis` variable \"", x_axis, "\" not found in the model."),
      hint = paste0("Specify one of the model's predictors (", backticked(predictor_vars),
                    "), such as 'x_axis = \"", predictor_vars[1],
                    "\"', or an expression of them.")
    )
  }

  # Extract original data (raw variables, not the model's transformed terms)
  orig_data <- slice_model_frame(model)

  # Error if that data has changed since the model was fitted
  check_slice_fit_data(model, orig_data, model_name)

  # Validate x-axis values are numeric
  x_obs <- eval(x_expr, orig_data)
  if (!is.numeric(x_obs)) {
    slice_abort(
      what = paste0("`x_axis` must be numeric; the class \"", class(x_obs)[1],
                    "\" is not supported."),
      hint = "Choose a numeric variable or expression for the x-axis."
    )
  }

  # Find all other variables in the model
  other_vars <- setdiff(predictor_vars, x_vars)

  # For each "other" variable, determine what value to hold it at
  other_vals <- lapply(other_vars, function(var) {
    if (!is.null(dots[[var]])) {
      dots[[var]]
    } else {
      col <- orig_data[[var]]
      if (is.numeric(col)) {
        m <- mean(col, na.rm = TRUE)
        slice_inform(
          what = paste0("Value for `", var, "` not specified - Used mean: ", round(m, 1)),
          hint = paste0("To specify, use 'var_name = value', such as '",
                        var, " = ", round(m, 1), "'")
        )
        m
      } else if (is.factor(col)) {
        l <- levels(col)[1]
        slice_inform(
          what = paste0("Value for `", var, "` not specified - Used first value: ", l),
          hint = paste0("To specify, use 'var_name = value', such as '",
                        var, " = ", l, "'")
        )
        l
      } else {
        slice_abort(
          what = paste0("The model variable `", var, "` has unsupported class \"",
                        class(col)[1], "\"."),
          hint = paste0(fn, "() supports numeric and factor predictors.")
        )
      }
    }
  })
  other_vals <- setNames(other_vals, other_vars)

  if (x_simple) {
    # One predictor varies: an evenly spaced sequence across its data range
    x_line <- seq(min(x_obs, na.rm = TRUE), max(x_obs, na.rm = TRUE), length.out = n)
    newdata <- setNames(data.frame(x_line), x_axis)
    for (var in other_vars) newdata[[var]] <- other_vals[[var]]
  } else {
    # The x-axis is an expression of several predictors: predict at the
    # model's own data points, and place each prediction at the row's
    # expression value. Held variables are never part of the x expression,
    # so overwriting them does not move the points along x. `n` is unused.
    newdata <- orig_data
    for (var in other_vars) newdata[[var]] <- other_vals[[var]]
    ord <- order(x_obs)
    newdata <- newdata[ord, , drop = FALSE]
    x_line <- x_obs[ord]
  }

  # Predict along the slice (a matrix of fit/lwr/upr when a confidence or
  # prediction interval is requested, a plain vector otherwise)
  preds <- predict(model, newdata = newdata, interval = interval)

  # Back-transform predictions onto the y-axis: FALSE means never, a function
  # is applied directly, NULL (the default) infers from the model formula
  inverse <- if (isFALSE(back_transform)) {
    identity
  } else if (is.function(back_transform)) {
    back_transform
  } else {
    get_inverse_function(formula(model)) %||% identity
  }

  if (is.matrix(preds)) {
    lo <- inverse(preds[, "lwr"])
    hi <- inverse(preds[, "upr"])
    # pmin/pmax keep the band upright when the inverse is decreasing (e.g. 1/x)
    line <- data.frame(x = x_line, fit = inverse(preds[, "fit"]),
                       lwr = pmin(lo, hi), upr = pmax(lo, hi))
  } else {
    line <- data.frame(x = x_line, fit = inverse(preds))
  }

  # Separate model values from plotting arguments in dots
  plot_args <- dots[!names(dots) %in% other_vars]

  # Generate caption
  caption_text <- ""
  for (i in seq_along(other_vars)) {
    if (i > 1) {
      caption_text <- paste0(caption_text, "; ")
    }
    if (is.numeric(other_vals[[i]])) {
      caption_text <- paste0(caption_text, other_vars[i], ": ", round(other_vals[[i]], 1))
    } else {
      caption_text <- paste0(caption_text, other_vars[i], ": ", other_vals[[i]])
    }
  }

  list(
    orig_data = orig_data,
    x_obs = x_obs,
    y_obs = orig_data[[y_name]],
    line = line,
    x_axis = x_axis,
    x_label = x_axis,
    y_name = y_name,
    plot_args = plot_args,
    caption_text = caption_text,
    other_vars = other_vars,
    other_vals = other_vals
  )
}



# On captioning
  # Because Base R uses a "painter" system, subsequent text appears on top of
  # the previous text caption. One solution is place future captions below the
  # previous, but the plot size can't be adjusted (it was already painted).
  # The next idea is to access the previous caption and update it. However,
  # it is simply drawn on the plot and not accessible as an object. So, it
  # could be made into an object and each caption an environment variable. This
  # has two more problems. It doesn't reset with a new plot, and therefore will
  # bleed into future plots. Additionally, a white rectangle needs to be
  # painted on top of the existing text to accommodate the new text.
  # Possible probably. Complicated definitely.
  #
  # By default it is on for slice_2d, but off for add_slice_2d, because slice_2d
  # creates a fresh plot with nothing to overwrite.
