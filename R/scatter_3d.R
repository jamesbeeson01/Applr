#' Plot a 3D-graphable linear model
#'
#' Creates an interactive 3D visualization of a linear model with exactly two
#' predictor variables. The model's own data is drawn as scattered points and a
#' semi-transparent regression surface is overlaid across the whole predictor
#' space, so you can *see* the fitted surface rather than read its coefficients.
#'
#' Reach for it when a model has exactly two predictors and you want to
#' understand how it behaves across their combinations. Transformed terms are
#' fine — the surface is evaluated with [predict()] on the raw predictors, so
#' `lm(z ~ x + I(x^2) + y)` graphs over `x` and `y` as expected.
#'
#' @param model A fitted [lm()] with exactly two numeric predictor variables.
#' @param n Number of grid points along each predictor axis used to evaluate
#'   the prediction surface (default 100); larger values give a smoother
#'   surface at the cost of speed.
#' @param colors Character vector defining the marker color gradient, mapped to
#'   the response value so points read from low to high.
#'
#' @returns A plotly object (an interactive 3D plot). When printed — e.g. at
#'   the console or in RStudio — it renders in the Viewer pane.
#'
#' @examples
#' if (interactive()) {
#'   # A flat regression plane over two predictors
#'   model <- lm(mpg ~ disp + hp, data = mtcars)
#'   scatter_3d(model)
#'
#'   # Custom marker gradient and a finer surface grid
#'   scatter_3d(model, n = 200, colors = c("blue", "yellow"))
#'
#'   # Transformed terms graph over their raw predictors
#'   curved <- lm(mpg ~ wt + I(wt^2) + hp, data = mtcars)
#'   scatter_3d(curved)
#'
#'   # Interaction models produce a twisted (non-planar) surface
#'   twisted <- lm(Sepal.Length ~ Sepal.Width * Petal.Length, data = iris)
#'   scatter_3d(twisted)
#' }
#'
#' @importFrom plotly plot_ly add_markers add_trace layout
#' @importFrom stats predict formula terms delete.response setNames
#'
#' @export
scatter_3d <- function(model, n = 100, colors = c("blue", "yellow")) {
  check_slice_model(model)

  # Read the axes from the formula's raw variables, not model$model's columns:
  # for lm(z ~ x + I(x^2) + y) the frame has an "I(x^2)" column, which would be
  # mistaken for a third predictor. all.vars() collapses transformed terms back
  # to the variables predict() actually needs.
  response <- all.vars(formula(model)[[2]])
  predictors <- setdiff(all.vars(delete.response(terms(model))), response)

  if (length(response) != 1) {
    slice_abort(
      what = paste0("scatter_3d() needs a single response variable, but `",
                    expr_text(formula(model)[[2]]), "` uses ", length(response), "."),
      hint = "Use a model whose left-hand side is one variable, such as 'lm(z ~ x + y, data = your_data)'."
    )
  }
  if (length(predictors) != 2) {
    slice_abort(
      what = paste0("scatter_3d() needs exactly two predictor variables, but the model has ",
                    length(predictors), "."),
      hint = "Reduce the model to two predictors, such as 'lm(z ~ x + y, data = your_data)'."
    )
  }

  # Raw fitting data — predict() needs the untransformed predictors, which
  # model$model does not carry for transformed terms.
  data <- slice_model_frame(model)
  x_name <- predictors[1]
  y_name <- predictors[2]

  for (var in predictors) {
    if (!is.numeric(data[[var]])) {
      slice_abort(
        what = paste0("scatter_3d() needs numeric predictors, but `", var,
                      "` is a \"", class(data[[var]])[1], "\"."),
        hint = "Use two numeric predictors, or reach for geom_slice() to show a categorical predictor as groups."
      )
    }
  }

  # A prediction grid across both predictors; predict() evaluates any
  # transformed terms itself from these raw values.
  x_axis <- seq(min(data[[x_name]]), max(data[[x_name]]), length.out = n)
  y_axis <- seq(min(data[[y_name]]), max(data[[y_name]]), length.out = n)
  grid <- setNames(expand.grid(x_axis, y_axis, KEEP.OUT.ATTRS = FALSE),
                   c(x_name, y_name))

  z <- tryCatch(
    predict(model, newdata = grid),
    error = function(e) {
      slice_abort(
        what = paste0("scatter_3d() could not evaluate the model across `",
                      x_name, "` and `", y_name, "`."),
        hint = "This happens when a predictor is transformed inside the formula (e.g. factor(x)); apply the transformation to the data and refit, such as 'lm(z ~ x + y, data = your_data)'."
      )
    }
  )
  # plotly's surface wants a matrix indexed [y, x]. expand.grid() varies the
  # first column fastest, so predictions fill an [x, y] matrix column by column;
  # transpose to the [y, x] orientation the trace expects.
  z_grid <- t(matrix(z, nrow = n, ncol = n))

  # A clean, safe-named frame lets us reference columns as ~x/~y/~z without the
  # backtick-escaping gymnastics that unusual variable names would otherwise
  # require (and without eval(parse())).
  points <- setNames(
    data.frame(data[[x_name]], data[[y_name]], data[[response]]),
    c("x", "y", "z")
  )

  plot_ly() |>
    add_markers(
      data = points,
      x = ~x, y = ~y, z = ~z,
      color = ~z, colors = colors,
      type = "scatter3d", mode = "markers"
    ) |>
    add_trace(x = x_axis, y = y_axis, z = z_grid, type = "surface", opacity = 0.6) |>
    layout(scene = list(
      xaxis = list(title = x_name),
      yaxis = list(title = y_name),
      zaxis = list(title = response)
    ))
}
