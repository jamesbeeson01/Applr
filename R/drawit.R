
#' Draw It function
#'
#' A function to draw singular slices of a model in base R. This function takes a more
#' strict approach by building the prediction equation from model coefficients
#' and requiring users to specify values for all predictor variables. Its original intent
#' is to be most useful for regression battleship, and as a learning tool. By requiring
#' entry of every value, it requires the student to think about what they are plotting.
#'
#' @param model A linear model using lm()
#' @param xaxis The xaxis of the plot and primary explanatory variable
#' @param ... Remaining variables; will throw warnings if not properly declared
#' @param col Color of the line
#' @param lty Line type
#'
#' @returns A slice of a linear model in a base R plot
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ wt + am + qsec, mtcars)
#' plot(mpg ~ wt, mtcars)
#' drawit(model = model, xaxis = 'wt',am = 1,qsec = 17, col='blue',lty=1)
#' }
#'
#' @importFrom graphics lines
#' @importFrom stats coef predict terms setNames formula predict.lm
#'
#' @export
drawit <- function(model,
                   xaxis,                # Required: which variable to vary along x-axis
                   ...,                  # User-specified values for other variables
                   col='black',          # Line color (default black)
                   lty=1){               # Line type (default solid)
  
  # Extract user-specified variable values from the ... arguments
  setvars <- list(...)
  
  # Get the original model data and variable names
  fullmodel <- model$model
  varsnames <- names(model$model)[-1]  # Exclude response variable (position 1)
  
  # Find variables that are not the x-axis variable
  # These are the variables we need to check for user specifications
  clean_varsnames <- setdiff(varsnames, xaxis)

  # Extract model coefficients and their names
  # Coefficients include intercept and slopes for each predictor/dummy variable
  b <- coef(model)
  numb <- length(b)
  nameb <- names(b)

  # Dynamically build the prediction equation as a string
  # This creates an expression like: b[1]*1 + b[2]*xaxis + b[3]*var1 + ...
  # where b[1] is intercept, b[2] is slope for xaxis, etc.
  curveequat <- paste0('b[',1:numb,']*',nameb, collapse = ' + ')
  
  # Remove the multiplication with "(Intercept)" to clean up the equation
  # The intercept term should just be b[1], not b[1]*(Intercept)
  clean_curveequat <- gsub('\\*\\(Intercept\\)', '', curveequat)

  # Create the code string that will be executed to draw the curve
  # The curve() function will evaluate our equation across the range of xaxis values
  curvecode <- paste0('curve(',clean_curveequat,', add = TRUE, xname =\"',xaxis,'\", col = \"', col,'\", lty =',lty,')')

  # Flag to track whether all required variables have been specified
  flag = FALSE

  # Process each variable that's not the x-axis variable
  for (name in clean_varsnames){
    
    # Handle numeric variables
    if (is.numeric(fullmodel[[name]])){
      # Get the range of values for this variable in the original data
      namerange <- range(model$model[[name]])
      
      # Check if user provided a value for this variable
      if (!name %in% names(setvars)){
        # Warn user that this variable needs a value
        warning(paste0(name,' value not specified; enter value between:',namerange[1],'-',namerange[2]))
        flag = TRUE  # Set flag to prevent drawing
      }
      else{
        # Assign the user-specified value to a variable with the same name
        # This allows the dynamic equation to reference it
        assign(name, setvars[[name]])
      }
    }
    # Handle categorical variables (factors or characters)
    else if (is.factor(model$model[[name]])| is.character(model$model[[name]])){
      # Get all possible levels/values for this categorical variable
      namelevels <- levels(model$model[[name]])
      levelslen <- length(namelevels)
      
      # Check if user provided a value for this variable
      if(!name %in% names(setvars)){
        # Warn user about available levels for this categorical variable
        warning(paste0(name,' value not specified; enter value as one of the following: ',paste0('\"',namelevels,'\"', collapse = ',')))
        flag = TRUE  # Set flag to prevent drawing
      }
      else{
        # For categorical variables, we need to handle dummy variable encoding
        # Convert user selection to character for comparison
        selected_level <- as.character((setvars[[name]]))
        
        # Find all dummy variables in the model coefficients that correspond to this factor
        # For a factor like "gear", we might have coefficients "gear4", "gear5", etc.
        dummyvars <- grep(name,names(b),value=TRUE)

        # Set appropriate dummy variables to 1 or 0 based on selected level
        for (dummy in dummyvars){
          # Extract the level name from the dummy variable name
          # E.g., from "gear4" extract "4"
          dummylevel <- sub(name,'',dummy)
          # Set this dummy to 1 if it matches selected level, 0 otherwise
          assign(dummy, as.numeric(dummylevel == selected_level))
        }
      }
    }
  }
  
  # Only draw the curve if all required variables have been specified
  if (!flag){
    # Execute the dynamically created curve drawing code
    # This will evaluate the linear equation across the range of x values
    eval(parse(text=curvecode))
  }
}
