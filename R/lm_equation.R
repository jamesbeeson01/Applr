# Shared core: coefficient values and display names for one fitted lm.
# Built from coef(model), NOT terms(model)'s term.labels — a factor expands
# into one coefficient per non-reference level (g -> gB, gC; x:g -> x:gB, ...),
# so term labels and coefficients don't line up (or even match in length).
# Coefficient names are the design-matrix column names and always align.
# NA coefficients (rank-deficient fits) are dropped: they contribute nothing
# to predictions and "NA*x" is not an equation.
lm_equation_parts <- function(model, clearer = FALSE) {
  co <- coef(model)
  co <- co[!is.na(co)]
  has_intercept <- names(co)[1] == "(Intercept)"
  slopes <- signif(if (has_intercept) co[-1] else co, 3)
  if (clearer) names(slopes) <- clearer_coef_names(names(slopes), model)
  list(
    response = deparse(formula(model)[[2]]),
    intercept = if (has_intercept) signif(co[[1]], 3),
    slopes = slopes
  )
}

# Rewrite dummy-coefficient names using the factor levels the model was fit
# with: gB -> (g="B"). Interaction terms are handled per ":"-separated piece,
# so x:gB -> x:(g="B"). Pieces that don't match a factor level (numeric
# predictors, I(...) terms) are left untouched.
clearer_coef_names <- function(coef_names, model) {
  xlevels <- model$xlevels
  if (is.null(xlevels) || length(xlevels) == 0) return(coef_names)
  rewrite_piece <- function(piece) {
    for (var in names(xlevels)) {
      for (lev in xlevels[[var]]) {
        if (piece == paste0(var, lev)) {
          return(paste0("(", var, "=\"", lev, "\")"))
        }
      }
    }
    piece
  }
  vapply(coef_names, function(nm) {
    paste(vapply(strsplit(nm, ":", fixed = TRUE)[[1]],
                 rewrite_piece, character(1)),
          collapse = ":")
  }, character(1), USE.NAMES = FALSE)
}

#' Write out the equation of a linear model
#'
#' Takes a fitted linear model and returns a human-readable equation string
#' showing the relationship between the response variable and predictors.
#' Coefficients are rounded to 3 significant figures for readability. Terms
#' are named as in the fitted coefficients, so factor predictors show one term
#' per dummy level (e.g. `2.1*gB`) and models without an intercept print no
#' intercept.
#'
#' @param model A linear model
#' @param clearer If `TRUE`, factor terms are displayed with the factor name
#'   and level spelled out (e.g. `4.09*(g="B")` instead of `4.09*gB`).
#'
#' @returns
#' The equation of an indicated linear model with coefficients and variable names
#'
#' @examples
#'\dontrun{
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' lm_equation(model)
#'}
#'
#' @importFrom graphics lines
#' @importFrom stats terms coef formula
#'
#' @export
lm_equation <- function(model, clearer = FALSE){
  parts <- lm_equation_parts(model, clearer = clearer)
  rhs <- paste0(parts$slopes, "*", names(parts$slopes), collapse = " + ")
  if (!is.null(parts$intercept)) rhs <- paste0(parts$intercept, " + ", rhs)
  # "+ -3*x" reads better as "- 3*x"
  gsub("\\+ -", "- ", paste0(parts$response, " = ", rhs))
}

#' Write out the equation of a linear model in LaTeX format
#'
#' Takes a fitted linear model and generates a properly formatted LaTeX
#' equation suitable for inclusion in R Markdown documents, academic papers,
#' or presentations. The output includes underbrace notation to clearly label
#' predicted values and predictor variables, making it ideal for educational
#' or presentation purposes. Coefficients are rounded to 3 significant
#' figures.
#'
#' @param model A linear model
#' @param clearer If `TRUE`, factor terms are displayed with the factor name
#'   and level spelled out (e.g. `(g="B")` instead of `gB`).
#'
#' @returns
#' The equation of an indicated linear model with coefficients and variable
#' names in LaTeX form, printed to the console and returned invisibly.
#'
#' @examples
#' \dontrun{
#' model <- lm(width ~ length + I(length^2) + sex + sex:length + sex:I(length^2), KidsFeet)
#' lm_latex(model)
#' }
#'
#' @importFrom graphics lines
#' @importFrom stats coef predict terms setNames formula predict.lm
#'
#' @export
lm_latex <- function(model, clearer = FALSE){
  parts <- lm_equation_parts(model, clearer = clearer)

  # Each coefficient becomes coef*\underbrace{X_{ki}}_{\text{name}}: math
  # notation on top, the design-matrix column name labeled underneath.
  x_nums <- paste0("X_{", seq_along(parts$slopes), "i}")
  x_under <- paste0("\\underbrace{", x_nums, "}_{\\text{",
                    names(parts$slopes), "}}")
  rhs <- paste0(parts$slopes, x_under, collapse = " + ")
  if (!is.null(parts$intercept)) rhs <- paste0(parts$intercept, " + ", rhs)
  rhs <- gsub("\\+ -", "- ", rhs)

  respon <- paste0("\\underbrace{\\hat{Y_i}}_{\\text{Pred. ",
                   parts$response, "}}")
  lat_equat <- paste0("$$", respon, " = ", rhs, "$$")

  cat(lat_equat)
  invisible(lat_equat)
}
