#' Generate an Inverse Function from a Formula LHS
#'
#' This function analyzes the Left-Hand Side (LHS) of a formula and constructs
#' a function that performs the mathematical inverse.
#'
#' @param f A formula (e.g., log(y) ~ x) or an expression/call.
#' @return A function accepting one argument (x) that returns the back-transformed value.
get_inverse_function <- function(f) {

  # 1. Extract the LHS expression from the formula
  if (inherits(f, "formula")) {
    # Formulas store the LHS in the second element
    expr <- f[[2]]
  } else {
    expr <- f
  }

  # 2. Helper: Check if an expression contains a variable (symbol)
  # We assume anything that is a 'name' (symbol) is the target variable
  has_var <- function(e) {
    if (is.name(e)) return(TRUE)
    if (is.call(e)) return(any(vapply(e[-1], has_var, logical(1))))
    return(FALSE)
  }

  # 3. Helper: Lookup table for standard unary inverses
  get_unary_inverse_op <- function(op_str) {
    map <- list(
      "log"   = quote(exp),
      "log10" = function(x) quote(10^x), # Dynamic construction
      "log2"  = function(x) quote(2^x),
      "log1p" = quote(expm1),
      "exp"   = quote(log),
      "expm1" = quote(log1p),
      "sqrt"  = function(x) call("^", x, 2),
      "sin"   = quote(asin),
      "cos"   = quote(acos),
      "tan"   = quote(atan),
      "asin"  = quote(sin),
      "acos"  = quote(cos),
      "atan"  = quote(tan)
    )

    if (op_str %in% names(map)) return(map[[op_str]])
    return(NULL)
  }

  # 4. Helper: Invert binary operations (+, -, *, /, ^, box_cox)
  # accum: The current inverse expression built so far (the 'x')
  # const: The constant value involved in the operation
  # on_left: Boolean, is the Variable on the LHS of the operator? (e.g. y - 5 vs 5 - y)
  invert_binary <- function(op, accum, const, on_left) {
    switch(op,
           "+" = call("-", accum, const), # Commutative
           "-" = if (on_left) call("+", accum, const) else call("-", const, accum),
           "*" = call("/", accum, const), # Commutative
           "/" = if (on_left) call("*", accum, const) else call("/", const, accum),
           "^" = if (on_left) call("^", accum, call("/", 1, const)) else call("/", call("log", accum), call("log", const)),

           # Special handling for Box Cox: box_cox(y, lambda)
           "box_cox" = {
             # Inverse of Box Cox: (lambda * x + 1)^(1/lambda)
             # We assume 'const' is lambda.
             lambda <- const

             # Handle lambda = 0 case (log)
             # Note: Since we are building an expression tree, we wrap this in a run-time check
             # using 'ifelse' inside the generated function body.
             call("ifelse",
                  call("==", lambda, 0),
                  call("exp", accum),
                  call("^", call("+", call("*", lambda, accum), 1), call("/", 1, lambda))
             )
           },
           stop(paste("Unknown binary operator:", op))
    )
  }

  # 5. Core Recursive Builder
  # Walks down the expression tree (expr) and builds the inverse tree (accum) outwards
  build_inverse <- function(expr, accum = quote(x)) {

    # Base Case: We hit the variable (e.g., 'y')
    if (is.name(expr)) {
      return(accum)
    }

    # Validation: Must be a call
    if (!is.call(expr)) {
      # It's a constant or something else; just return as is (rare edge case)
      return(expr)
    }

    op_sym <- expr[[1]]
    op_str <- as.character(op_sym)
    args <- as.list(expr[-1])

    # --- Case A: Unary Function (e.g., log(y)) ---
    if (length(args) == 1) {
      inv_op <- get_unary_inverse_op(op_str)

      if (is.null(inv_op)) stop(paste("No inverse known for unary function:", op_str))

      # Wrap the accumulator: e.g., if accum is 'x', make it 'exp(x)'
      # Handle dynamic builders (like sqrt returning power call)
      if (is.function(inv_op)) {
        new_accum <- inv_op(accum)
      } else {
        new_accum <- call(as.character(inv_op), accum)
      }

      return(build_inverse(args[[1]], new_accum))
    }

    # --- Case B: Binary Function (e.g., y + 1) ---
    if (length(args) == 2) {
      left <- args[[1]]
      right <- args[[2]]

      var_left <- has_var(left)
      var_right <- has_var(right)

      if (var_left && var_right) stop("Cannot invert: variable appears on both sides of operator.")
      if (!var_left && !var_right) stop("No variable found to invert.")

      # Identify which side is the variable structure and which is constant
      target_branch <- if (var_left) left else right
      constant_val  <- if (var_left) right else left

      new_accum <- invert_binary(op_str, accum, constant_val, on_left = var_left)

      return(build_inverse(target_branch, new_accum))
    }

    stop("Complex functions with >2 arguments are not supported.")
  }

  # 6. Construct the final function
  tryCatch({
    # Build the expression body
    final_body <- build_inverse(expr)

    # Create the function object
    f_inv <- function(x) {}
    body(f_inv) <- final_body
    environment(f_inv) <- baseenv() # Clean environment

    return(f_inv)

  }, error = function(e) {
    message("Error creating inverse: ", e$message)
    return(NULL)
  })
}
