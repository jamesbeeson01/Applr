#' Write out the equation of a linear model
#'
#' Takes a fitted linear model and returns a human-readable equation string showing
#' the relationship between the response variable and predictors. This is useful for
#' presenting model results in reports or understanding the mathematical form of the model.
#' Coefficients are rounded to 3 significant figures for readability.
#'
#' @param model A linear model
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
#' @importFrom stats terms
#'
#' @export
lm_equation <- function(model){

# Extract the predictor variable names from the model terms
# terms() gets the formula structure, attr(..., "term.labels") gets just the predictor names
model_vars <- attr(terms(model), "term.labels")

# Get the name of the response (dependent) variable
# This is always the first column in the model$model data frame
model_y <- names(model$model)[1]

# Extract and round the slope coefficients (excluding intercept)
# coefficients[1] is intercept, coefficients[2:end] are slopes
# signif() rounds to 3 significant figures for cleaner presentation
model_coef <- signif(model$coefficients,3)[-1]

# Extract and round the intercept coefficient
model_intercept <- signif(model$coefficients,3)[1]

# Build the right-hand side of the equation by combining coefficients with variable names
# Format: coef1*var1 + coef2*var2 + ...
# collapse combines all terms with " + " separator
model_terms <- paste0(model_coef, '*', model_vars, collapse = ' + ')

# Combine all parts into the full equation
# Format: response = intercept + slope1*var1 + slope2*var2 + ...
model_equation <- paste0(model_y, ' = ', model_intercept, ' + ', model_terms)

# Clean up the equation by replacing "+ -" with "- " for negative coefficients
# This makes expressions like "y = 5 + -3*x" become "y = 5 - 3*x"
model_equation <- gsub("\\+ -", "- ", model_equation)

# Return the formatted equation string
model_equation

}

#' Write out the equation of a linear model in LaTeX format
#'
#' Takes a fitted linear model and generates a properly formatted LaTeX equation
#' suitable for inclusion in R Markdown documents, academic papers, or presentations.
#' The output includes underbrace notation to clearly label predicted values and
#' predictor variables, making it ideal for educational or presentation purposes.
#' Coefficients are rounded to 3 significant figures.
#'
#' @param model A linear model
#'
#' @returns
#' The equation of an indicated linear model with coefficients and variable names in LaTeX form
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
lm_latex <- function(model){

  # Extract the predictor variable names from the model terms
  model_vars <- attr(terms(model), "term.labels")
  
  # Get the name of the response (dependent) variable
  model_y <- names(model$model)[1]

  # Extract and round the slope coefficients (excluding intercept)
  # signif() rounds to 3 significant figures for cleaner presentation
  model_coef <- signif(model$coefficients,3)[-1]
  
  # Extract and round the intercept coefficient
  model_intercept <- signif(model$coefficients,3)[1]

  # Create LaTeX variable notation for predictors
  # Format: X_{1i}, X_{2i}, X_{3i}, etc. for mathematical notation
  x_nums <- paste0('X_{',seq_along(model_vars),'i}')
  
  # Combine the mathematical notation with descriptive underbraces
  # Format: \underbrace{X_{1i}}_{\text{variable_name}}
  # This creates variables with labels underneath showing the actual variable names
  x_under <- paste0("\\underbrace{", x_nums, "}_{\\text{", model_vars, "}}")
  
  # Build the predictor terms by combining coefficients with the labeled variables
  # Format: coef1*\underbrace{X_{1i}}_{\text{var1}} + coef2*\underbrace{X_{2i}}_{\text{var2}} + ...
  x_terms <- paste0(model_coef,x_under, collapse = ' + ')
  
  # Clean up negative coefficients in the equation
  # Replace "+ -" with "- " for proper mathematical formatting
  x_terms <- gsub("\\+ -", "- ", x_terms)

  # Create LaTeX notation for the response variable with descriptive underbrace
  # Format: \underbrace{\hat{Y_i}}_{\text{Pred. response_name}}
  # \hat{Y_i} indicates predicted values, underbrace labels it with the actual variable name
  respon <- paste0('\\underbrace{\\hat{Y_i}}_{\\text{Pred. ',model_y,'}}')

  # Combine all parts into the complete LaTeX equation
  # Format: $$\underbrace{\hat{Y_i}}_{\text{Pred. response}} = intercept + terms$$
  # The $$ delimiters create a displayed (centered) equation in LaTeX
  lat_equat <- paste0('$$',respon, ' = ',model_intercept, ' + ', x_terms,'$$')

  # Output the LaTeX equation to the console
  # cat() prints without quotes, making it easy to copy-paste into LaTeX documents
  cat(lat_equat)
}
