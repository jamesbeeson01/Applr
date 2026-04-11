
#' StatSlice
#'
#' A custom 'ggproto' object designed to take a high dimensional model,
#' pull the aesthetics from the global environment, and then create predictions
#' to display a slice of the high dimensional model.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{Stat}
#'
#' @section Parameters:
#' \describe{
#' \item{model}{A fitted linear model object from 'lm()'}
#' \item{predict_vars}{A list of specified variables and values that specify the displayed slice}
#' \item{n}{The number of predicted points generated}
#' }
#'
#' @section Internal Methods:
#' \describe{
#' \item{get_default_value}{An internal function that determines the mean of numeric columns or most common factor in fator/character columns and holds that value constant}
#' \item{compute_group}{Generates prediction data for each group within each facet of a 'ggplot' graph}
#' }
#'
#' @import ggplot2
#' @import rlang
#'
#' @export
StatSlice <- ggproto(
  "StatSlice",
  StatIdentity,
  # Required aesthetics - x and y must be mapped in the ggplot call
  required_aes = c('x','y'),

  # Setup function - simply passes data through unchanged
  # This is a standard ggproto method for any initial data preparation
  setup_data = function(self, data, params){
    data
  },

  # Helper function to determine default values for variables not explicitly set
  # This is called when a model variable isn't specified in predict_vars
  get_default_value = function(model, varname) {
    # Extract the specific variable's data from the fitted model
    fdata <- model$model[[varname]]

    # For numeric variables, use the mean as a reasonable default
    if (is.numeric(fdata)) {
      val <- mean(fdata, na.rm = TRUE)
    }
    # For categorical variables (factors or characters), use the most frequent value
    else if (is.factor(fdata) || is.character(fdata)) {
      # Count frequency of each level/value
      freq <- table(fdata)
      # Get the most common value
      val <- names(freq)[which.max(freq)]
      # Preserve factor structure if original was a factor
      if (is.factor(fdata))
        val <- factor(val, levels = levels(fdata))
    } else {
      # Error for unsupported data types
      stop("Unsupported column type: ", class(data))
    }

    # Notify the user of the value chosen
    message(paste("Value for", varname, "not specified. Using value ", val))

    # Return imputed value
    val
  },

  # Helper function to detect and handle response variable transformations
  # Uses the parsed model terms structure rather than text parsing
  detect_response_transform = function(model, yvar, back_transform = NULL) {
    # If user manually specified back_transform, use it
    if (!is.null(back_transform)) {
      if (is.function(back_transform)) {
        return(list(
          needs_transform = TRUE,
          back_transform_fn = back_transform,
          warned = FALSE
        ))
      } else if (is.character(back_transform)) {
        # Convert string to function
        back_transform_fn <- switch(
          tolower(back_transform),
          "log" = exp,
          "log10" = function(x) 10^x,
          "log2" = function(x) 2^x,
          "sqrt" = function(x) x^2,
          "sqrtsqrt" = function(x) x^4,
          "square" = sqrt,
          "squared" = sqrt,
          "exp" = log,
          "inverse" = function(x) 1/x,
          "1/x" = function(x) 1/x,
          stop("Unknown transformation type: ", back_transform)
        )
        return(list(
          needs_transform = TRUE,
          back_transform_fn = back_transform_fn,
          warned = FALSE
        ))
      }
    }

    # Get the response variable from the parsed model terms
    # This extracts the actual R call object, not just text
    model_terms <- terms(model)
    response_expr <- attr(model_terms, "variables")[[2]]  # [[1]] is 'list', [[2]] is response

    # Check if response is a simple variable or a function call
    if (is.name(response_expr)) {
      # Simple case: lm(y ~ x)
      detected_var <- as.character(response_expr)
      transform_type <- NULL
    } else if (inherits(response_expr, "call")) {
      # Function call case: lm(log(y) ~ x) or lm(sqrt(y) ~ x)
      func_name <- as.character(response_expr[[1]])

      # Extract the base variable (assuming simple transformations like log(y))
      # For more complex cases like log(y + 1), this would need enhancement
      if (length(response_expr) >= 2 && is.name(response_expr[[2]])) {
        detected_var <- as.character(response_expr[[2]])
        transform_type <- func_name
      } else {
        # Complex transformation we can't easily parse
        detected_var <- deparse(response_expr)
        transform_type <- NULL
      }
    } else {
      # Fallback to text representation
      detected_var <- deparse(response_expr)
      transform_type <- NULL
    }

    # Compare the detected variable with the y-axis variable
    if (detected_var != yvar) {
      # The variables don't match - issue warning
      if (is.null(transform_type)) {
        # No transformation detected, but variables are different
        warning(
          "Y-axis variable '", yvar, "' does not match model response variable '",
          detected_var, "'. The model predictions may not display correctly.",
          call. = FALSE
        )
      }
      return(list(
        needs_transform = FALSE,
        back_transform_fn = NULL,
        warned = TRUE
      ))
    }

    # If we detected a transformation and the base variable matches y-axis
    if (!is.null(transform_type) && detected_var == yvar) {
      # Lookup table for inverse functions
      inverse_map <- list(
        "log" = exp,
        "log10" = function(x) 10^x,
        "log2" = function(x) 2^x,
        "sqrt" = function(x) x^2,
        "exp" = log
      )

      back_transform_fn <- inverse_map[[transform_type]]

      if (!is.null(back_transform_fn)) {
        message(
          "Detected transformation '", transform_type, "' on response variable. ",
          "Automatically back-transforming predictions to match y-axis scale."
        )

        return(list(
          needs_transform = TRUE,
          back_transform_fn = back_transform_fn,
          warned = FALSE
        ))
      }
    }

    # No transformation needed or unknown transformation
    return(list(
      needs_transform = FALSE,
      back_transform_fn = NULL,
      warned = FALSE
    ))
  },

  # Pass facet layout information to the parameters for use in compute_panel
  # This allows the stat to work correctly with faceted plots
  compute_layer = function(self, data, params, layout){
    params$facet_layout <- layout$layout
    mapping <- params$mapping
    # Call the parent method to handle the actual computation
    ggproto_parent(Stat,self)$compute_layer(data,params,layout)
  },

  # Main computation function - this is where the model predictions are generated
  # This function runs once for each group within each panel/facet in the plot
  compute_group = function(data, scales, params, n = 100, facet_layout,
                           predict_vars, model, mapping, back_transform = NULL) {

    # Start by getting needed information

    # Identify which variables are used for faceting (grouping subplots)
    # These are excluded from standard facet layout columns
    facet_vars <- setdiff(names(facet_layout),
                          c("ROW", 'COL', "SCALE_X", "SCALE_Y", "COORD"))

    # Extract variable names from the aesthetic mapping
    # These determine which variables are on the x and y axes
    xvar <- rlang::as_name(rlang::quo_get_expr(mapping$x))
    yvar <- rlang::as_name(rlang::quo_get_expr(mapping$y))

    # Check if response variable needs transformation handling
    # Now using the model object directly instead of text parsing
    transform_info <- StatSlice$detect_response_transform(model, yvar, back_transform)

    # Get all variable names from the original model
    vars <- names(model$model) #Identify col names from model

    # Create prediction data frame
    new_data <- select(data[1,], !x)

    # Join the facet information with the main data
    # This ensures each panel knows its facet variable values
    new_data <- facet_layout |>
      select(facet_vars) |>
      right_join(new_data, by = "PANEL")

    # Create n evenly spaced x values from min to max
    # This creates a smooth line instead of using the original data points
    x_min <- min(data$x, na.rm = TRUE)
    x_max <- max(data$x, na.rm = TRUE)

    # Generate the sequence of x values for prediction
    x <- seq(x_min, x_max, length.out = n)

    # Join new x values to data frame (expects new_data to have 1 row only)
    new_data <- cbind(x, new_data)

    # This puts the original column names on the data for predict() to function
    # `mapping` is a listlike data structure with quosures at its next level
    # `disp` would be a name class, but `as.factor(disp)` would not.
    # A note: This is not my favorite solution, but current best.
    #   An ideal one would use the original data filtered by the current group
    #   so it retains the correct name and class. This implementation just pulls
    #   column names, and if something like as.factor(disp) was used, this will
    #   pull out just disp. It assumes that the correct column name is the last
    #   in any expression. This will likely break, but rare enough that it works
    original_names <- lapply(mapping, FUN = function(x) {
      a <- x[[2]]
      while (class(a) != "name") {
        a <- a[[length(a)]]
      }
      a
    })

    # reverse names and items in list for ease of use, then rename data columns
    original_names <- setNames(names(original_names), unlist(original_names))
    new_data <- rename(new_data, !!!original_names)

    # Add facet variable values from this panel
    # for (facet_var in facet_vars) {
    #   # All rows in this panel have the same facet variable value
    #   facet_value <- unique(data[[facet_var]])[1]
    #   new_data[[facet_var]] <- facet_value
    # }
#-------------I'm here
    # Find variables that are in the model but not on axes or in facets
    # These are the variables we need to set to specific values for the slice
    othervars <- setdiff(vars, c(xvar, yvar, facet_vars))

    # Set values for each "other" variable (not x, y, or facet variables)
    for (var in othervars) {
      # If user specified a value for this variable, use it
      if (!is.null(predict_vars[[var]])) {
        new_data[[var]] <- predict_vars[[var]]
      } else {
        # Otherwise, use the default value (mean for numeric, mode for categorical)
        new_data[[var]] <- StatSlice$get_default_value(model, var)
      }
    }

    # Ensure facet variables have the correct data types to match the original model
    # This prevents type mismatches that could cause prediction errors
    for (facet_var in facet_vars) {
      if (is.factor(model$model[[facet_var]])) {
        new_data[[facet_var]] <- factor(new_data[[facet_var]], levels = levels(model$model[[facet_var]]))
      } else if (is.character(model$model[[facet_var]])) {
        new_data[[facet_var]] <- as.character(new_data[[facet_var]])
      } else if (is.numeric(model$model[[facet_var]])) {
        new_data[[facet_var]] <- as.numeric(new_data[[facet_var]])
      }
    }

    # Generate predictions using the model and the prepared data
    # This creates the y-values for the slice line
    y <- predict(model, newdata = new_data)

    # Apply back-transformation if needed
    if (!is.null(transform_info$back_transform_fn)) {
      y <- transform_info$back_transform_fn(y)
    }

    # Return the original data with new x and y values
    cbind(x, y, select(data[1,], !c(x, y)))
  }
)

#' GeomSlice
#'
#' A custom 'ggproto' object that provides the graphing aesthetics
#' for the 'StatSlice' object. This defines how the slice lines should look.
#' It is essentially GeomLine with modified aesthetics
#'
#' @export
GeomSlice <- ggproto(
  'GeomSlice',
  # Inherits from GeomLine (which inherits from Geom),
  # since we're drawing lines to represent model slices
  GeomLine,
  # Default aesthetic values for the slice lines
  # Users can override these by passing arguments to geom_slice()
  default_aes = aes(
    color = "skyblue",      # Light blue color for visibility
    linewidth = 1,          # Medium line thickness
    linetype = "solid",     # Solid line (not dashed or dotted)
    alpha = 1)              # Fully opaque
)

#' geom_slice
#'
#' A 'ggplot' layer that takes a high dimensional model and displays the predicted
#' model across each facet of a graph. This is the main user-facing function for
#' adding model slices to ggplot2 graphs.
#'
#' @param model A linear model provided by 'lm()'
#' @param n The number of predicted points across the graph - default 100
#' @param inherit.aes Inherits the aes provided by 'ggplot' object
#' @param predict_vars A list of specified variables and values that specify the slice - not required
#' @param back_transform Optional. Either NULL (auto-detect), a function for back-transforming predictions,
#'   or a character string ("log", "log10", "log2", "sqrt", "exp", "inverse") specifying the transformation
#'   to reverse. Use this when the model has a transformed response variable (e.g., log(y)) but the plot
#'   displays the original scale.
#' @param ... Other variables (color, alpha, etc.)
#'
#' @returns A ggplot layer that displays the slice of the high dimensional model
#' @examples
#' \dontrun{
#' # Example: Using geom_slice without specifying 'predict_vars'
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(x=disp,y=mpg))+
#' geom_point()+
#' facet_wrap(~hp)+
#' geom_slice(model=model)
#'
#' # Example: Using geom_slice with 'predict_vars'
#' model <- lm(mpg ~ disp + hp + gear, data = mtcars)
#' ggplot(mtcars, aes(x=disp, y=mpg))+
#' geom_point()+
#' facet_wrap(~hp)+
#' geom_slice(model=model, predict_vars=list(gear=4))
#'
#' # Example: Model with log transformation (auto-detected)
#' model <- lm(log(mpg) ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(x=disp, y=mpg))+
#' geom_point()+
#' geom_slice(model=model, predict_vars=list(hp=110))
#'
#' # Example: Manual back-transformation specification
#' model <- lm(log(mpg) ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(x=disp, y=mpg))+
#' geom_point()+
#' geom_slice(model=model, back_transform="log")
#'}
#'
#' @export
geom_slice <- function(
    model,                    # Required: the fitted linear model
    n = 100,                  # Number of points to generate for smooth line
    inherit.aes = TRUE,       # Whether to inherit aesthetics from main ggplot call
    predict_vars = list(),    # Optional: specific values for model variables
    back_transform = NULL,    # Optional: back-transformation for response variable
    ...                       # Additional aesthetic parameters (color, size, etc.)
  ) {

  # Create the basic layer using ggplot2's layer() function
  # This combines our custom Stat and Geom with standard ggplot2 infrastructure
  my_layer <- layer(
    stat = StatSlice,         # Use our custom stat to compute predictions
    geom = GeomSlice,         # Use our custom geom to draw lines
    position = 'identity',    # Don't adjust positions (unlike 'dodge' or 'jitter')
    inherit.aes = inherit.aes,
    # Pass all the parameters to the stat computation
    params = list(model = model,predict_vars = predict_vars, n = n, back_transform = back_transform, ...)
  )

  # Return a custom ggproto object that extends the basic layer
  # This handles the complex interaction between stat computation and the layer system
  SliceLayer <- ggproto(
    "SliceLayer", my_layer,
    # Custom method to handle the statistic computation
    # This ensures our StatSlice gets the right data and parameters
    compute_statistic = function(self, data, layout){
      # Set up parameters for the stat computation
      params <- self$stat$setup_params(data, self$stat_params)
      # Store the aesthetic mapping for use in computation
      self$computed_stat_params <- params[['mapping']] <- self$computed_mapping

      # Prepare the data for computation
      data <- self$stat$setup_data(data,params)

      # Perform the actual statistical computation (prediction generation)
      self$stat$compute_layer(data,params,layout)

    }
  )

  # Return the layer
  SliceLayer
}


