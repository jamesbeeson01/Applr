# Shared core: coefficient values and display names for one fitted lm.
# Built from coef(model), NOT terms(model)'s term.labels — a factor expands
# into one coefficient per non-reference level (g -> gB, gC; x:g -> x:gB, ...),
# so term labels and coefficients don't line up (or even match in length).
# Coefficient names are the design-matrix column names and always align.
# NA coefficients (rank-deficient fits) are dropped: they contribute nothing
# to predictions and "NA*x" is not an equation.
lm_equation_parts <- function(model, format = c("prettier", "brackets", "raw")) {
  format <- match.arg(format)
  co <- coef(model)
  co <- co[!is.na(co)]
  has_intercept <- names(co)[1] == "(Intercept)"
  slopes <- signif(if (has_intercept) co[-1] else co, 3)
  if (format != "raw") {
    names(slopes) <- pretty_coef_names(names(slopes), model, format)
  }
  list(
    response = deparse(formula(model)[[2]]),
    intercept = if (has_intercept) signif(co[[1]], 3),
    slopes = slopes
  )
}

# Rewrite dummy-coefficient names using the factor levels the model was fit
# with: gB -> (g="B") for "prettier", or the shorter gB -> [B] for "brackets".
# Interaction terms are handled per ":"-separated piece, so x:gB ->
# x:(g="B"). Pieces that don't match a factor level (numeric predictors,
# I(...) terms) are left untouched.
pretty_coef_names <- function(coef_names, model, format = "prettier") {
  xlevels <- model$xlevels
  if (is.null(xlevels) || length(xlevels) == 0) return(coef_names)
  rewrite_piece <- function(piece) {
    for (var in names(xlevels)) {
      for (lev in xlevels[[var]]) {
        if (piece == paste0(var, lev)) {
          return(if (format == "brackets") {
            paste0("[", lev, "]")
          } else {
            paste0("(", var, "=\"", lev, "\")")
          })
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
#' Use it when you want to report or sanity-check a fitted model as an
#' equation rather than a coefficient table — for example when writing up
#' homework or checking which dummy terms a factor produced.
#'
#' @param model A linear model
#' @param format How factor terms are named. `"prettier"` (the default)
#'   spells out the factor name and level (e.g. `4.09*(Species="setosa")`),
#'   `"brackets"` shows the level alone (e.g. `4.09*[setosa]`), and `"raw"`
#'   keeps the design-matrix names (e.g. `4.09*Speciessetosa`).
#'
#' @return A character string of length 1 containing the fitted equation,
#'   e.g. `"mpg = 30.7 - 0.0248*disp - 0.0245*hp"`.
#'
#' @examples
#' # Simple regression
#' lm_equation(lm(mpg ~ wt, data = mtcars))
#'
#' # Multiple predictors
#' lm_equation(lm(mpg ~ disp + hp, data = mtcars))
#'
#' # Factor predictor: one term per non-reference level, spelled out by default
#' model <- lm(Sepal.Length ~ Sepal.Width + Species, data = iris)
#' lm_equation(model)
#'
#' # `format = "brackets"` shows just the level; `"raw"` keeps design-matrix names
#' lm_equation(model, format = "brackets")
#' lm_equation(model, format = "raw")
#'
#' # Transformed terms and interactions
#' lm_equation(lm(mpg ~ wt + I(wt^2), data = mtcars))
#' lm_equation(lm(Sepal.Length ~ Sepal.Width * Species, data = iris))
#'
#' # No-intercept models print no intercept
#' lm_equation(lm(mpg ~ 0 + wt, data = mtcars))
#'
#' @export
lm_equation <- function(model, format = c("prettier", "brackets", "raw")){
  parts <- lm_equation_parts(model, format = match.arg(format))
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
#' Use it when a model needs to appear as typeset math — in an R Markdown
#' chunk with `results = "asis"`, the LaTeX string prints ready to render.
#'
#' @param model A linear model
#' @param format How factor terms are labelled. `"prettier"` (the default)
#'   spells out the factor name and level (e.g. `(Species="setosa")`),
#'   `"brackets"` shows the level alone (e.g. `[setosa]`), and `"raw"` keeps
#'   the design-matrix names (e.g. `Speciessetosa`).
#'
#' @return A character string of length 1 containing the display-math LaTeX
#'   equation (wrapped in `$$...$$`), printed to the console with `cat()` and
#'   returned invisibly.
#'
#' @examples
#' # Simple regression
#' lm_latex(lm(mpg ~ wt, data = mtcars))
#'
#' # Multiple predictors and a transformed term
#' lm_latex(lm(mpg ~ disp + hp + I(hp^2), data = mtcars))
#'
#' # Factor predictor with interactions, spelled out by default
#' model <- lm(Sepal.Length ~ Sepal.Width * Species, data = iris)
#' lm_latex(model)
#'
#' # `format = "brackets"` shows just the level; `"raw"` keeps design-matrix names
#' lm_latex(model, format = "brackets")
#' lm_latex(model, format = "raw")
#'
#' # Capture the string instead of just printing it
#' eq <- lm_latex(lm(mpg ~ wt, data = mtcars))
#' nchar(eq)
#'
#' @export
lm_latex <- function(model, format = c("prettier", "brackets", "raw")){
  parts <- lm_equation_parts(model, format = match.arg(format))

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
