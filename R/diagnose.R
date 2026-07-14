#' Diagnostic plots for linear models
#'
#' Generates a set of three diagnostic plots for a linear model object, side
#' by side: Residuals vs Fitted (checks linearity and constant variance),
#' Normal Q-Q (checks normality of residuals), and residuals in data order
#' (checks independence). Use it right after fitting a model to check the
#' regression assumptions in one call instead of building each plot yourself.
#' Graphical parameters (`mfrow`) are restored on exit.
#'
#' @param model An object of class \code{lm}.
#'
#' @return None. The function is called for its side effect of producing plots.
#'
#' @export
#'
#' @examples
#' # Simple regression
#' diagnose(lm(mpg ~ wt, data = mtcars))
#'
#' # Works the same for multiple regression
#' diagnose(lm(mpg ~ wt + hp + disp, data = mtcars))
#'
#' # A poorly-specified model shows curvature in Residuals vs Fitted
#' diagnose(lm(dist ~ speed, data = cars))
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
