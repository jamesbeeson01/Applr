
#' Plot a 3D-grapheable linear model
#'
#' Creates an interactive 3D visualization of a linear model with exactly 2 predictor variables.
#' The function plots the original data points as scattered points in 3D space and overlays
#' a semi-transparent regression surface showing the model predictions across the entire
#' predictor space. This provides an intuitive way to understand how a linear model
#' behaves across different combinations of two predictor variables.
#'
#' @param model A saved linear model with 2 predictor variables
#' @param n Number of evaluations for creating the surface grid
#' @param colors Colors used for the gradient scale
#'
#' @returns A 3D graph in the viewer section
#'
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' scatter_3d(model, colors=c('blue','yellow'))
#' }
#'
#' @importFrom tidyr pivot_wider
#' @importFrom plotly plot_ly add_markers add_trace
#' @importFrom graphics lines
#' @importFrom stats coef predict terms setNames formula predict.lm
#'
#' @export
scatter_3d <- function(model, n=100, colors = c('blue', 'yellow')){

  # Validate that the input is a linear model
  if (!inherits(model, 'lm'))
    stop('Model must be in lm format')

  # Extract all variable names from the model formula
  # This includes the response variable and all predictors
  vars <- all.vars(formula(model))

  # Check that model has exactly 3 variables (1 response + 2 predictors)
  # More than 3 variables cannot be meaningfully displayed in 3D
  if(length(vars) > 3)
    stop('Not 3D Graphable, Reduce lm to 2 predictor variables')

  # Extract the data for response and predictor variables from the fitted model
  # The model$model data frame contains the original data used to fit the model
  y <- model$model[1][[1]]        # Response variable (e.g., mpg)
  x1 <- model$model[2][[1]]       # First predictor (e.g., disp)
  x2 <- model$model[3][[1]]       # Second predictor (e.g., hp)

  # Get variable names for labeling axes
  y_name <- names(model$model)[1]   # Response variable name
  x1_name <- names(model$model)[2]  # First predictor name
  x2_name <- names(model$model)[3]  # Second predictor name

  # Create a clean data frame with proper column names for plotting
  df <- setNames(data.frame(y,x1,x2), c(y_name, x1_name, x2_name))

  # Ensure x1 is numeric for creating the 3D surface
  # Convert factors to numeric values if necessary
  if (!is.numeric(x1)) {
    if (!is.factor(x1)) x1 <- as.factor(x1)  # Convert to factor first if character
    x1 <- as.numeric(x1)                      # Then convert to numeric
  }

  # Ensure x2 is numeric for creating the 3D surface
  # Convert factors to numeric values if necessary
  if (!is.numeric(x2)) {
    if (!is.factor(x2)) x2 <- as.factor(x2)  # Convert to factor first if character
    x2 <- as.numeric(x2)                      # Then convert to numeric
  }

  # Create sequences of values across the range of each predictor
  # These will form a grid for generating the prediction surface
  axisx <- seq(min(x1), max(x1), length.out=n)  # x1 values for surface
  axisy <- seq(min(x2), max(x2), length.out=n)  # x2 values for surface

  # Create a grid of all combinations of x1 and x2 values
  # expand.grid creates a data frame with every combination of the input vectors
  surface <- expand.grid(setNames(list(axisx, axisy), c(x1_name,x2_name)), KEEP.OUT.ATTRS = F)

  # Ensure factor levels are preserved if original variables were factors
  # This is important for proper prediction with categorical variables
  if (is.factor(x1))
    surface[[x1_name]] <- factor(surface[[x1_name]], levels = levels(x1))

  if (is.factor(x2))
    surface[[x2_name]] <- factor(surface[[x2_name]], levels = levels(x2))

  # Generate predictions for every point on the surface grid
  # This creates the Z-values (height) for the 3D surface
  surface$Z <- predict.lm(model, newdata = surface)

  # Reshape the surface data from long format to wide format
  # This creates a matrix suitable for plotly's surface plotting
  # Each row represents a y-axis value, each column an x-axis value
  widesurface <- pivot_wider(
    surface,
    names_from = !!sym(x1_name),      # Columns will be x1 values
    values_from = Z                    # Cell values will be predictions
  )

  # Convert to matrix format and set row names for the surface plot
  surface <- as.matrix(widesurface[,-1])           # Remove first column (x2 values)
  rownames(surface) <- widesurface[[x2_name]]     # Set row names as x2 values

  # Create the 3D plot using plotly
  # This uses dynamic code generation to handle variable names properly
  eval(parse(text=paste0("plot_ly() %>%",
    # Add the original data points as 3D scatter points
    "add_markers(data=df,",
         "x=~",x1_name,",",              # x-axis: first predictor
         "y=~",x2_name,",",              # y-axis: second predictor  
         "z=~",y_name,",",               # z-axis: response variable
         "type='scatter3d',",
         "mode='markers',",
         "colors = colors) %>%",
    # Add the regression surface
    "add_trace(z=surface,",             # z-values: predicted responses
              "x=axisx,",               # x-values: first predictor range
              "y=axisy,",               # y-values: second predictor range
              "type='surface',",
              "opacity = 0.6)")))       # Semi-transparent surface
}
