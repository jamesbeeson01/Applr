#' Diagnostic plots for linear models
#'
#' Generates a set of three diagnostic plots for a linear model object:
#' Residuals vs Fitted, Normal Q-Q, and a plot of the residuals.
#'
#' @param model An object of class \code{lm}.
#'
#' @return None. The function is called for its side effect of producing plots.
#'
#' @export
#'
#' @examples
#' lm_model <- lm(mpg ~ wt, data = mtcars)
#' diagnose(lm_model)
diagnose <- function(model) {
  if (!inherits(model, "lm")) {
    stop("model must be an object of class 'lm'")
  }

  op <- par("mfrow")       # save current graphical parameters
  on.exit(par(mfrow = op)) # ensure they get restored automatically

  # Display diagnostic plots
  par(mfrow = c(1,3))
  plot(model, which = 1:2)
  plot(model$res)
}
