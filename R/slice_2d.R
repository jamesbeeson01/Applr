#' 2D Slicer
#'
#' Take a linear model and display a 2D slice in base R. This function creates
#' a new plot comparing the response y variable with one predictor x variable
#' and displaying a linear model line with all other predictor variables
#' held at constant values. For unspecified variables, the xaxis is assumed
#' to be the first predictor in the model and all other variable are imputed
#' (mean for numeric, most common for factors).
#'
#' @param model A linear model
#' @param xaxis A non-required specification of the xaxis variable; default is first x var in lm
#' @param n Number of displayed points; default is 100
#' @param caption Boolean to include caption with values of predictor variables not shown in the chart, TRUE by default
#' @param back_transform Either 1) A function to back transform the predicted y values and interval bounds (e.g., `exp` or `\(x) exp(x)` for log-transformed models), or 2) a boolean stating whether it should apply a transformation or not (`FALSE` turns off back_transform). In most cases, this does not need to be specified as the function infers the transformation needed reliably.
#' @param ... Remaining vars (color, linetype, etc.)
#'
#' @returns A 2D graph of a sliced model
#'
#' @importFrom graphics lines
#' @importFrom stats coef predict terms setNames formula predict.lm
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ disp, data = mtcars)
#' slice_2d(model, xaxis = 'disp')
#' }
#'
#' @export
slice_2d <- function(model,xaxis=NULL,n=100,caption=TRUE, back_transform=TRUE, ...){

  # Prepare data
  prep <- prepare_slice_data(model, xaxis, n, caption, back_transform, ...)

  orig_data <- prep$orig_data
  new_data <- prep$new_data
  xaxis <- prep$xaxis
  y_name <- prep$y_name
  plot_args <- prep$plot_args
  caption_text <- prep$caption_text

  # PLOT

  # Create the base plot with original data points
  plot(orig_data[[y_name]] ~ orig_data[[xaxis]],
       xlab = xaxis,
       ylab = y_name,
       main = deparse(formula(model)),
       pch = 19,
       col = "steelblue")

  # Add the prediction line to show the model slice
  # do.call used for lines function to allow a list "plot_args" in place of ...
  do.call(lines, c(list(x = new_data[[xaxis]], y = new_data$preds), plot_args))

  # Add a caption with predictor values that aren't visible in the plot
  # While this is functional to some extent, it has a clear complex problem,
  # which is detailed at the bottom of the file.
  if (caption) {
    # Add the caption to the plot
    mtext(caption_text, # text
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
#' @param xaxis A non-required specification of the xaxis variable; default is first x var in lm
#' @param n Number of displayed points; default is 100
#' @param caption Boolean to include caption with values of predictor variables not shown in the chart, FALSE by default
#' @param back_transform Either 1) A function to back transform the predicted y values and interval bounds (e.g., `exp` or `\(x) exp(x)` for log-transformed models), or 2) a boolean stating whether it should apply a transformation or not (`FALSE` turns off back_transform). In most cases, this does not need to be specified as the function infers the transformation needed reliably.
#' @param ... Remaining vars (color, linetype, etc.)
#'
#' @returns A line added to a preexisting R plot displaying a 2D graphable slice of an HD model
#'
#' @importFrom graphics lines
#' @importFrom stats coef predict terms setNames formula predict.lm
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' plot(mpg ~ disp, data = mtcars)
#' add_slice_2d(model,xaxis='disp', hp=100)
#' }
#'
#' @export
add_slice_2d <- function(model,xaxis=NA,n=100,caption=FALSE, back_transform=TRUE, ...){

  # Prepare data
  prep <- prepare_slice_data(model, xaxis, n, caption, back_transform, ...)

  new_data <- prep$new_data
  xaxis <- prep$xaxis
  plot_args <- prep$plot_args
  caption_text <- prep$caption_text

  # Warn if the slice is outside the current plot window
  usr <- try(par("usr"), silent = TRUE)
  if (!inherits(usr, "try-error") && is.numeric(usr)) {
    xlim <- usr[1:2]; ylim <- usr[3:4]
    xr <- range(new_data[[xaxis]], na.rm = TRUE)
    yr <- range(new_data$preds, na.rm = TRUE)
    if (xr[2] < xlim[1] || xr[1] > xlim[2] || yr[2] < ylim[1] || yr[1] > ylim[2]) {
      warning("Slice is outside the current plot range; the line may not be visible or aligned.")
    }
  }

  # Add the prediction line to the existing plot
  # Note: This assumes a plot already exists - it will error if no plot is active
  # do.call used for lines function to allow a list "plot_args" in place of ...
  do.call(lines, c(list(x = new_data[[xaxis]], y = new_data$preds), plot_args))

  # Add a caption with predictor values that aren't visible in the plot
  if (caption) {
    # Add the caption to the plot
    mtext(caption_text, # text
          side = 3, # Top margin
          line = 0.5, # Just under the title (line 0.5)
          adj = 0, # Left-align
          # cex = 0.8, # Smaller text size
          col = "gray40")
  }
}


# This data preparation is shared by both slice_2d and add_slice_2d
prepare_slice_data <- function(model, xaxis, n, caption, back_transform=TRUE, ...) {
  # Validate that the input is a linear model
  if (!inherits(model, 'lm')) {
    stop("Model must be in lm() format")
  }

  # Check for '$' in variable names
  for (name in names(model$model)) {
    if (grepl("\\$", name)) stop("Cannot use lm with '$' in its variable names")
  }

  # Get original variable names
  var_names <- all.vars(formula(model))
  y_name <- var_names[1]

  # Determine xaxis if not specified
  if (is.null(xaxis) || is.na(xaxis)) {
    xaxis <- var_names[2]  # Position 1 is the response variable
    message(paste0("X-axis not specified - Used first x variable as x-axis",
                   "\n    To specify, use 'xaxis = \"var_name\"' such as 'xaxis = \"",
                   xaxis, "\"'"))
  }

  # Validate that the specified x-axis variable exists in the model
  if (!(xaxis %in% var_names)) {
    stop(paste0("xaxis variable '", xaxis, "' not found in the model."))
  }

  # Extract original data
  if (!is.null(model$call$data)) {
    orig_data <- eval(model$call$data, envir = environment(formula(model)))
  } else {
    orig_data <- data.frame(
      sapply(var_names, FUN = \(v) get(v, environment(formula(model))))
    )
  }

  # Validate x-axis variable is numeric
  if (!is.numeric(orig_data[[xaxis]])) {
    stop(paste0("`xaxis` must be numeric; the class \"", class(orig_data[[xaxis]]), "\" is not supported."))
  }

  # Find all other variables in the model
  other_vars <- setdiff(var_names, c(y_name, xaxis))

  # Get any arguments passed via ...
  dots <- list(...)

  # For each "other" variable, determine what value to hold it at
  other_vals <- lapply(other_vars, function(var) {
    if (!is.null(dots[[var]])) {
      dots[[var]]
    } else {
      col <- orig_data[[var]]
      if (is.numeric(col)) {
        m <- mean(col, na.rm = TRUE)
        message(paste0("Value for `", var, "` not specified -",
                       " Used mean: ", round(m, 1),
                       "\n    To specify, use 'var_name = value', such as '",
                       var, " = ", round(m, 1), "'"))
        m
      } else if (is.factor(col)) {
        l <- levels(col)[1]
        message(paste0("Value for `", var, "` not specified -",
                       " Used first value: ", l,
                       "\n    To specify, use 'var_name = value', such as '",
                       var, " = ", l, "'"))
        l
      } else {
        stop(paste0("Unsupported variable type for: `", var, "`"))
      }
    }
  })

  # Convert the constant values into a data frame format
  x_names <- as.data.frame(as.list(setNames(other_vals, other_vars)))

  # Create an evenly spaced sequence of values across the range of the x axis
  x_vals <- seq(min(orig_data[[xaxis]], na.rm = TRUE), max(orig_data[[xaxis]], na.rm = TRUE), length.out = n)

  # Prepare x values for the predict() function
  new_data <- setNames(data.frame(x_vals), xaxis)

  # Add the constant values for all other variables
  if (length(other_vars) > 0) {
    new_data <- cbind(new_data, x_names)
  }

  # Create y-values for all the new data points
  new_data$preds <- predict(model, newdata = new_data)

  # Get y transformation
  # If they say no, don't transform
  if (is.logical(back_transform) && back_transform == FALSE) {
    inverse <- identity

  # If they specify a valid function, go with that
  } else if (is.function(back_transform) && length(formals(back_transform)) == 1) {
    inverse <- back_transform

  # Otherwise, infer the back transformation
  } else if (is.logical(back_transform) && back_transform == TRUE) {
    inverse <- get_inverse_function(formula(model))

  # And if they specified something invalid, warn them
  } else {
    warning(paste0("The back_transform argument`", back_transform,
                  "` is not a valid function or boolean.",
                  "\n    Inferring transformation from lm."))
    inverse <- get_inverse_function(formula(model))
  }

  # Apply transformation
  new_data$preds <- inverse(new_data$preds)

  # Separate model values from plotting arguments in ...
  plot_args <- dots[!names(dots) %in% other_vars]

  # Generate caption
  caption_text <- ""
  if (caption) {
    for (i in seq_along(other_vars)) {
      if (i > 1) {
        caption_text <- paste0(caption_text, "; ")
      }
      if (is.numeric(other_vals[[i]])) {
        caption_text <- paste0(caption_text, other_vars[i], ": ", round(other_vals[[i]], 1))
      } else {
        caption_text <- paste0(caption_text, other_vars[i], ": ", other_vals[i])
      }
    }
  }

  list(
    orig_data = orig_data,
    new_data = new_data,
    xaxis = xaxis,
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
