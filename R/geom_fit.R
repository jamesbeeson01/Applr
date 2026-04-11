#' Model Prediction Layers for ggplot2
#'
#' Creates prediction or confidence interval ribbons and a line of best fit based on a statistical model, attempting to mimic geom_smooth, but with finer controls specific to a provided linear model.
#' This function uses `predict()` to generate values across the range of the primary predictor
#' variable found in the model. It allows for specifying the type of interval ('confidence' or 'prediction'),
#' applying a transformation function to the predictions and intervals, and providing additional
#' predictor values via the `new_data` argument. It returns ggplot2 layers suitable for adding to an existing plot.
#' Note: Assumes the model has a structure where the primary predictor can be inferred as the first variable in the model (i.e. beta 1). This must be your x variable.
#'
#' @param model A linear model (lm()) to create a line from using predict(). The function attempts to automatically extract the primary predictor (x) variable from the model object.
#' @param new_data An optional data frame containing values for other predictor variables in the model (if any) to be held constant during prediction. If `NA` (default), predictions are made only based on the primary predictor sequence. Note: The current internal implementation uses `cbind`, ensure `new_data` is structured appropriately (e.g., a single row data frame with the constant values).
#' @param resolution An integer specifying the number of points across the range of the primary predictor (x) at which to evaluate the model. Default is 500.
#' @param color A character string specifying the color for the resultant line and ribbon. Default is "blue".
#' @param interval A character string specifying the type of interval required: "confidence" (default) or "prediction". Passed to `predict()`.
#' @param back_transform Either 1) A function to back transform the predicted y values and interval bounds (e.g., `exp` or `\(x) exp(x)` for log-transformed models), or 2) a boolean stating whether it should apply a transformation or not (`FALSE` turns off back_transform). In most cases, this does not need to be specified as the function infers the transformation needed reliably.
#' @param se Removes confidence band if specified FALSE (similar to geom_smooth). Defaults to TRUE
#'
#' @return A list containing two ggplot2 layer objects: a `geom_ribbon` for the interval and a `geom_line` for the fitted values.
#'
#' @importFrom ggplot2 aes geom_ribbon geom_line ggplot geom_point
#' @importFrom dplyr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Example dataset with two predictors
#' set.seed(123)
#' df <- data.frame(
#'   x = 1:20,
#'   group = factor(rep(c("A", "B"), each = 10)),
#'   y = 0.5 * (1:20) + ifelse(rep(c("A", "B"), each = 10) == "B", 5, 0) + rnorm(20)
#' )
#'
#' # Fit a linear model
#' fit <- lm(y ~ x + group, data = df)
#'
#' # Base plot
#' p <- ggplot(df, aes(x = x, y = y, color = group))
#'
#' # Add prediction lines and confidence intervals for each group
#' # Note: geom_fit varies 'x', holds 'group' constant via 'new_data'
#' p +
#'   geom_fit(fit, new_data = data.frame(group = "A"), color = "red") +
#'   geom_fit(fit, new_data = data.frame(group = "B"), color = "blue", interval = "prediction")
#'
#' # Example with log transformation
#' df_log <- data.frame(x = 1:10, y = exp(0.5 + 0.2*(1:10) + rnorm(10, sd = 0.1)))
#' fit_log <- lm(log(y) ~ x, data = df_log)
#' ggplot(df_log, aes(x = x, y = y)) +
#'  geom_point() +
#'  geom_fit(fit_log, transform = exp, color = "purple")
#' }

geom_fit <- function(model, new_data = NA, resolution = 500, color = "blue", interval = "confidence", back_transform = TRUE, se = TRUE) {

  # Extract predictor values from model
  x <- model$model[[2]]
  predictor_name <- names(model$model)[2]  # Get predictor variable name

  # Create a sequence of x values across the range
  x_seq <- seq(min(x), max(x), length.out = resolution)

  # Create a new data frame for prediction with correct column name
  pred_data <- setNames(data.frame(x_seq), predictor_name) %>% cbind(new_data)

  # Obtain predictions with confidence intervals
  preds <- predict(model, pred_data, interval = interval)

  # Get y transformation
  # If it they say no, don't transform
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
    warning(paste0("The back_transform argument `", back_transform,
                  "` is not a valid function or boolean.",
                  "\n    Inferring transformation from lm."))
    inverse <- get_inverse_function(formula(model))
  }

  # Apply the transformation to the predicted fit and its confidence bounds
  predicted_data <- data.frame(
    x    = x_seq,
    y    = inverse(preds[, "fit"]),
    ymin = inverse(preds[, "lwr"]),
    ymax = inverse(preds[, "upr"])
  )

  # These can be added to an existing ggplot.
  if (se) {
    list(
      geom_ribbon(
        data = predicted_data,
        mapping = aes(x = x, ymin = ymin, ymax = ymax),
        fill = color, alpha = 0.2,
        inherit.aes = FALSE
      ),
      geom_line(
        data = predicted_data,
        mapping = aes(x = x, y = y),
        color = color, linewidth = 1,
        inherit.aes = FALSE
      )
    )
  } else {
    geom_line(
      data = predicted_data,
      mapping = aes(x = x, y = y),
      color = color, linewidth = 1,
      inherit.aes = FALSE
    )
  }
}


geom_add_slice_2d <- function(model, xaxis=NA, n=100, back_transform=TRUE, color = "blue", ...){

  # Prepare data
  prep <- prepare_slice_data(model, xaxis, n, FALSE, back_transform, ...)

  new_data <- prep$new_data
  xaxis <- prep$xaxis
  y_name <- prep$y_name
  plot_args <- prep$plot_args
  caption_text <- prep$caption_text

  # Update x name for easy ggplot graphing
  names(new_data)[1] <- "x"

  # Add the prediction line to the existing plot
  geom_line(
    data = new_data,
    mapping = aes(x = x, y = preds),
    color = color, linewidth = 1,
    inherit.aes = FALSE
  )
}
