# geom_slice() — draw a 2D slice of a fitted lm() as a ggplot2 layer.
#
# Architecture (background in for_devs/ggplot_layer_internals.Rmd):
#
#   geom_slice()   validates user input, then builds a standard ggplot2 layer
#                  with `layer_class = SliceLayer`.
#   SliceLayer     a thin Layer subclass whose only job is to hand the layer's
#                  computed aesthetic mapping to the stat, then defer to
#                  ggplot2's own machinery for everything else.
#   StatSlice      compute_layer() resolves the "slice plan" once per layer
#                  (which model variable is on each axis, which are pinned by
#                  groups/facets, which are held constant, how predictions map
#                  onto the y-axis); compute_group() then builds one prediction
#                  line per group from that plan.
#   GeomSlice      GeomLine with slice-flavored default aesthetics.
#
# The stat needs the aesthetic mapping because the slice is defined in terms of
# the *model's* variables: the x-axis expression decides which predictor varies,
# grouping/facet aesthetics pin predictors per group, and the y-axis expression
# decides whether predictions must be back-transformed. ggplot2 does not pass
# the mapping to stats, so SliceLayer injects it into the stat parameters at
# the one point in the build where it is fully resolved.


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Deparse an expression to a single one-line string.
expr_text <- function(expr) {
  paste(trimws(deparse(expr)), collapse = " ")
}

# Format a value for use in messages and copy-pasteable hints.
format_value <- function(value) {
  if (is.numeric(value)) format(signif(value, 4)) else paste0('"', value, '"')
}

# The raw (untransformed) variables the model was fitted on, as a data frame.
# `model$model` is unusable for this: for lm(y ~ I(x^2)) it contains a column
# literally named "I(x^2)", not `x` — but predict() needs `x`.
slice_model_frame <- function(model) {
  env <- environment(formula(model))
  tryCatch(
    {
      if (is.null(model$call$data)) {
        get_all_vars(formula(model))
      } else {
        get_all_vars(formula(model), eval(model$call$data, env))
      }
    },
    error = function(e) {
      slice_abort(
        what = "The data the model was fitted on could not be found.",
        hint = "Fit the model with a data argument, such as 'lm(y ~ x, data = your_data)'."
      )
    }
  )
}

# Coerce a value recovered from the plot (facet layout, aesthetic column, or
# predict_vars) back to the type of the model variable it pins.
coerce_like <- function(value, template, var) {
  if (is.factor(template)) {
    value <- as.character(value)
    if (!value %in% levels(template)) {
      slice_abort(
        what = paste0("\"", value, "\" is not a level of the model's factor `", var, "`."),
        hint = paste0("Use one of: ", paste0('"', levels(template), '"', collapse = ", "), ".")
      )
    }
    return(factor(value, levels = levels(template)))
  }
  if (is.numeric(template)) {
    coerced <- suppressWarnings(as.numeric(as.character(value)))
    if (is.na(coerced) && !is.na(value)) {
      slice_abort(
        what = paste0("Value \"", value, "\" for the numeric variable `", var, "` is not a number."),
        hint = paste0("Use a number, such as '", var, " = ", format_value(mean(template, na.rm = TRUE)), "'.")
      )
    }
    return(coerced)
  }
  if (is.character(template)) {
    return(as.character(value))
  }
  value
}

# Default value for a model variable that is not shown on the plot:
# mean for numeric, most common value for factor/character.
# Announces the choice so users know the slice is one of many.
impute_value <- function(column, var) {
  if (is.numeric(column)) {
    value <- mean(column, na.rm = TRUE)
    label <- paste0("Used mean: ", format_value(value))
  } else if (is.factor(column) || is.character(column)) {
    counts <- table(column)
    value <- names(counts)[which.max(counts)]
    label <- paste0("Used most common: \"", value, "\"")
    if (is.factor(column)) value <- factor(value, levels = levels(column))
  } else {
    slice_abort(
      what = paste0("The model variable `", var, "` has unsupported class \"", class(column)[1], "\"."),
      hint = "geom_slice() supports numeric, factor, and character predictors."
    )
  }
  slice_inform(
    what = paste0("Value for `", var, "` not specified - ", label),
    hint = paste0("To choose a slice, use 'predict_vars = list(", var, " = ",
                  format_value(value), ")'.")
  )
  value
}

# Panel-scale transformation, as a list with $transform and $inverse.
# Positional scales transform data *before* the stat sees it, so the stat must
# inverse-transform panel x back to data units for predict(), and forward-
# transform predicted y into panel units (e.g. under scale_y_log10()).
scale_transformation <- function(scale, axis) {
  if (is.null(scale)) {
    return(list(transform = identity, inverse = identity))
  }
  if (scale$is_discrete()) {
    slice_abort(
      what = paste0("geom_slice() needs a continuous ", axis, "-axis, but the ",
                    axis, " scale is discrete."),
      hint = "Map a numeric variable or expression to this axis."
    )
  }
  trans <- tryCatch(scale$get_transformation(), error = function(e) NULL)
  if (is.null(trans)) {
    return(list(transform = identity, inverse = identity))
  }
  trans
}

# The known names accepted by `back_transform = "<name>"`.
back_transform_names <- list(
  "log"     = exp,
  "log10"   = function(x) 10^x,
  "log2"    = function(x) 2^x,
  "sqrt"    = function(x) x^2,
  "exp"     = log,
  "inverse" = function(x) 1 / x,
  "1/x"     = function(x) 1 / x
)

# Validate and normalize `back_transform` at construction time.
# Returns NULL (auto-detect), FALSE (never transform), or a function.
check_back_transform <- function(back_transform) {
  if (is.null(back_transform)) return(NULL)
  if (is.logical(back_transform) && length(back_transform) == 1 && !is.na(back_transform)) {
    # TRUE means auto-detect, which is already the default
    return(if (back_transform) NULL else FALSE)
  }
  if (is.character(back_transform) && length(back_transform) == 1) {
    fn <- back_transform_names[[tolower(back_transform)]]
    if (is.null(fn)) {
      slice_abort(
        what = paste0("\"", back_transform, "\" is not a known `back_transform` name."),
        hint = paste0("Use one of ", paste0('"', names(back_transform_names), '"', collapse = ", "),
                      ", or pass a function such as 'back_transform = exp'.")
      )
    }
    return(fn)
  }
  if (is.function(back_transform)) {
    fmls <- formals(args(back_transform))
    required <- if (length(fmls) == 0) character(0) else {
      names(fmls)[vapply(fmls, function(d) identical(d, quote(expr = )), logical(1))]
    }
    if (length(fmls) == 0 || length(required) > 1) {
      slice_abort(
        what = "The `back_transform` function must take exactly one argument.",
        hint = "Use a one-argument function, such as 'back_transform = function(x) 1/x'."
      )
    }
    return(back_transform)
  }
  slice_abort(
    what = paste0("`back_transform` must be TRUE/FALSE, a one-argument function, ",
                  "or a transformation name; received a \"", class(back_transform)[1], "\"."),
    hint = "Use a function such as 'back_transform = exp', or 'back_transform = FALSE' to turn it off."
  )
}

check_slice_model <- function(model) {
  if (missing(model) || is.null(model)) {
    slice_abort(
      what = "geom_slice() needs a fitted model.",
      hint = "Fit one first, such as 'model <- lm(y ~ x, data = your_data)', then call 'geom_slice(model)'."
    )
  }
  if (!inherits(model, "lm")) {
    slice_abort(
      what = paste0("`model` must be a model fitted by `lm()`; received a \"", class(model)[1], "\"."),
      hint = "Fit the model first, such as 'model <- lm(y ~ x, data = your_data)'."
    )
  }
  dollar <- grep("\\$", names(model$model), value = TRUE)
  if (length(dollar) > 0) {
    slice_abort(
      what = paste0("Models with `$` in their variable names (`", dollar[1], "`) are not supported."),
      hint = "Refit using the data argument, such as 'lm(y ~ x, data = your_data)'."
    )
  }
  invisible(model)
}

check_predict_vars <- function(predict_vars, model) {
  if (length(predict_vars) == 0) return(invisible(predict_vars))
  if (!is.list(predict_vars) || is.null(names(predict_vars)) || any(names(predict_vars) == "")) {
    slice_abort(
      what = "`predict_vars` must be a named list of variable = value pairs.",
      hint = "For example, 'predict_vars = list(hp = 110)'."
    )
  }
  formula_vars <- all.vars(formula(model))
  response_vars <- all.vars(formula(model)[[2]])
  predictor_vars <- setdiff(all.vars(delete.response(terms(model))), response_vars)
  for (var in names(predict_vars)) {
    if (var %in% response_vars) {
      slice_abort(
        what = paste0("`", var, "` is the model's response and cannot be held at a value."),
        hint = "Only predictors can be set in `predict_vars`."
      )
    }
    if (!var %in% predictor_vars) {
      slice_abort(
        what = paste0("`predict_vars` variable \"", var, "\" not found in the model."),
        hint = paste0("The model's predictors are ",
                      paste0("`", predictor_vars, "`", collapse = ", "),
                      ".")
      )
    }
    if (length(predict_vars[[var]]) != 1) {
      slice_abort(
        what = paste0("`predict_vars` value for `", var, "` must be a single value."),
        hint = paste0("For example, 'predict_vars = list(", var, " = 1)'.")
      )
    }
  }
  invisible(predict_vars)
}

# Build the function that maps raw predict() output onto the plot's y-axis
# (before any y-scale transformation). Handles, in order of priority:
#   - explicit `back_transform` (FALSE or a function),
#   - y-axis showing the response in the same space as the model (identity),
#   - a transformed response (log(y) ~ ...) shown on the raw y axis
#     (inverted via get_inverse_function()),
#   - a y-axis *expression* of the response variable (aes(y = log(y))).
resolve_y_fn <- function(model, y_quo, back_transform) {
  response_expr <- formula(model)[[2]]
  response_text <- expr_text(response_expr)
  y_expr <- rlang::quo_get_expr(y_quo)
  y_text <- expr_text(y_expr)

  if (isFALSE(back_transform)) return(identity)
  if (is.function(back_transform)) return(back_transform)

  # Same expression on both sides: predictions are already in y-axis space.
  if (identical(response_text, y_text)) return(identity)

  response_vars <- all.vars(response_expr)
  y_vars <- all.vars(y_expr)
  if (length(response_vars) != 1 || length(y_vars) != 1 || response_vars != y_vars) {
    slice_warn(
      what = paste0("The y-axis `", y_text, "` does not match the model's response `",
                    response_text, "`; the line may not display correctly."),
      hint = "Plot the response variable on the y-axis, or supply 'back_transform ='."
    )
    return(identity)
  }

  # Same base variable, different expressions. Undo the model's response
  # transformation, then apply the y-axis expression.
  inverse <- identity
  if (!is.name(response_expr)) {
    inverse <- suppressMessages(get_inverse_function(response_expr))
    if (is.null(inverse)) {
      slice_warn(
        what = paste0("Could not infer the inverse of the model's response `", response_text, "`."),
        hint = "Supply it directly, such as 'back_transform = exp'."
      )
      return(identity)
    }
  }
  forward <- identity
  if (!is.name(y_expr)) {
    var <- y_vars
    forward <- function(v) rlang::eval_tidy(y_quo, data = setNames(list(v), var))
  }
  slice_inform(
    what = paste0("Predictions of `", response_text, "` were back-transformed to match the `",
                  y_text, "` axis."),
    hint = "To turn this off, use 'back_transform = FALSE'."
  )
  function(v) forward(inverse(v))
}

# Resolve the slice plan once per layer. Returns a list consumed by
# compute_group(): which predictor varies along x, which variables are pinned
# per group/facet, which are held constant (with what values), and how raw
# predictions map onto the y-axis.
build_slice_spec <- function(params, layout) {
  model <- params$model
  mapping <- params$mapping
  predict_vars <- params$predict_vars %||% list()

  if (is.null(mapping$x) || is.null(mapping$y)) {
    slice_abort(
      what = "geom_slice() needs both `x` and `y` mapped in aes().",
      hint = "For example, 'ggplot(your_data, aes(x = disp, y = mpg))'."
    )
  }

  raw_data <- slice_model_frame(model)
  response_vars <- all.vars(formula(model)[[2]])
  predictor_vars <- setdiff(all.vars(delete.response(terms(model))), response_vars)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")

  # --- x axis: one predictor (simple mode) or an expression (composite mode) --
  x_quo <- mapping$x
  x_expr <- rlang::quo_get_expr(x_quo)
  x_simple <- is.name(x_expr)
  x_vars <- intersect(all.vars(x_expr), predictor_vars)
  if (length(x_vars) == 0) {
    slice_warn(
      what = paste0("The x-axis `", expr_text(x_expr),
                    "` uses none of the model's predictors, so the slice will be a flat line."),
      hint = paste0("The model's predictors are ", backticked(predictor_vars), ".")
    )
  }

  # --- grouping: aesthetics mapped to a single model predictor pin that
  # --- predictor to each group's own value
  group_aes <- list()
  for (aes_name in setdiff(names(mapping), c("x", "y"))) {
    expr <- rlang::quo_get_expr(mapping[[aes_name]])
    vars <- all.vars(expr)
    if (length(vars) != 1 || !vars %in% predictor_vars) next
    if (aes_name == "group") {
      # group values are turned into opaque integer ids before the stat runs,
      # so the original values cannot be recovered from a bare group aes
      slice_warn(
        what = paste0("`group = ", expr_text(expr), "` cannot pin `", vars,
                      "` to each group's value, so it will be held constant instead."),
        hint = paste0("Map it to a visible aesthetic, such as 'aes(color = ", expr_text(expr), ")'.")
      )
    } else {
      group_aes[[aes_name]] <- vars
    }
  }

  # --- faceting: facet variables that are model predictors pin per panel ---
  facet_layout <- layout$layout
  layout_cols <- setdiff(names(facet_layout),
                         c("PANEL", "ROW", "COL", "SCALE_X", "SCALE_Y"))
  facet_vars <- intersect(layout_cols, predictor_vars)

  # --- explicit predict_vars win over group/facet pinning ---
  pinned_by_user <- names(predict_vars)
  group_aes <- group_aes[!unlist(group_aes) %in% pinned_by_user]
  facet_vars <- setdiff(facet_vars, pinned_by_user)
  on_axis <- intersect(pinned_by_user, x_vars)
  if (length(on_axis) > 0) {
    slice_warn(
      what = paste0("`predict_vars` value for ", backticked(on_axis),
                    " is ignored because it is on the x-axis."),
      hint = "The x-axis variable varies along the line and cannot be held."
    )
  }

  # --- held variables: everything the plot does not show ---
  held_vars <- setdiff(predictor_vars, c(x_vars, unlist(group_aes), facet_vars))
  held <- list()
  for (var in held_vars) {
    held[[var]] <- if (!is.null(predict_vars[[var]])) {
      coerce_like(predict_vars[[var]], raw_data[[var]], var)
    } else {
      impute_value(raw_data[[var]], var)
    }
  }

  list(
    model = model,
    raw_data = raw_data,
    x_quo = x_quo,
    x_simple = x_simple,
    group_aes = group_aes,
    facet_vars = facet_vars,
    facet_layout = facet_layout,
    held = held,
    y_fn = resolve_y_fn(model, mapping$y, params$back_transform)
  )
}

# Build one prediction line for one group, following the layer's slice spec.
compute_slice_group <- function(data, scales, spec, n) {
  if (nrow(data) == 0) return(data)

  x_trans <- scale_transformation(scales$x, "x")
  y_trans <- scale_transformation(scales$y, "y")

  # Values pinned by this group's panel and aesthetics
  pinned <- list()
  panel_row <- spec$facet_layout[spec$facet_layout$PANEL == data$PANEL[1], , drop = FALSE]
  for (var in spec$facet_vars) {
    pinned[[var]] <- coerce_like(panel_row[[var]][1], spec$raw_data[[var]], var)
  }
  for (aes_name in names(spec$group_aes)) {
    var <- spec$group_aes[[aes_name]]
    if (!is.null(data[[aes_name]])) {
      pinned[[var]] <- coerce_like(data[[aes_name]][1], spec$raw_data[[var]], var)
    }
  }

  if (spec$x_simple) {
    # One predictor varies: an even grid across this group's x range
    # (per group, not per panel — see "X Range" in for_devs/decisions.Rmd),
    # inverse-transformed to data units for predict().
    x_panel <- seq(min(data$x, na.rm = TRUE), max(data$x, na.rm = TRUE), length.out = n)
    x_var <- as.character(rlang::quo_get_expr(spec$x_quo))
    newdata <- setNames(data.frame(x_trans$inverse(x_panel)), x_var)
    for (var in names(pinned)) newdata[[var]] <- pinned[[var]]
    for (var in names(spec$held)) newdata[[var]] <- spec$held[[var]]
  } else {
    # The x-axis is an expression of several predictors: predict at the
    # model's own data points (filtered to this group), and place each
    # prediction at the row's x-axis expression value.
    rows <- spec$raw_data
    for (var in names(pinned)) {
      keep <- !is.na(rows[[var]]) & rows[[var]] == pinned[[var]]
      if (any(keep)) rows <- rows[keep, , drop = FALSE]
    }
    for (var in names(spec$held)) rows[[var]] <- spec$held[[var]]
    newdata <- rows
    x_panel <- x_trans$transform(rlang::eval_tidy(spec$x_quo, data = rows))
  }

  predictions <- tryCatch(
    predict(spec$model, newdata = newdata),
    error = function(e) {
      slice_abort(
        what = paste0("predict() failed for this slice: ", conditionMessage(e)),
        hint = "Check that `predict_vars` values match the model's variable types."
      )
    }
  )
  y_panel <- y_trans$transform(spec$y_fn(predictions))

  ord <- order(x_panel)
  extra <- data[1, setdiff(names(data), c("x", "y")), drop = FALSE]
  data.frame(x = x_panel[ord], y = y_panel[ord], extra, row.names = NULL)
}


# ---------------------------------------------------------------------------
# ggproto classes
# ---------------------------------------------------------------------------

#' StatSlice
#'
#' The stat behind [geom_slice()]. Once per layer it resolves a "slice plan"
#' from the model and the plot's aesthetic mapping (which predictor varies
#' along x, which are pinned by groups/facets, which are held constant, and
#' how predictions map onto the y-axis); then, for each group, it generates
#' an `n`-point prediction line from the model.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{Stat}.
#'
#' @import ggplot2
#' @import rlang
#'
#' @export
StatSlice <- ggproto(
  "StatSlice",
  Stat,
  required_aes = c("x", "y"),
  extra_params = c("na.rm", "mapping"),

  # Resolve the slice plan once per layer (imputation messages fire once here,
  # not once per group), then let ggplot2's standard machinery split the data
  # by panel and group.
  compute_layer = function(self, data, params, layout) {
    params$slice_spec <- build_slice_spec(params, layout)
    ggproto_parent(Stat, self)$compute_layer(data, params, layout)
  },

  compute_group = function(data, scales, model, predict_vars = list(),
                           back_transform = NULL, n = 100, mapping = NULL,
                           slice_spec = NULL, na.rm = FALSE) {
    compute_slice_group(data, scales, slice_spec, n)
  }
)

#' GeomSlice
#'
#' The geom behind [geom_slice()]: [ggplot2::GeomLine] with slice-flavored
#' default aesthetics.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{GeomLine}.
#'
#' @export
GeomSlice <- ggproto(
  "GeomSlice",
  GeomLine,
  default_aes = aes(
    color = "skyblue",
    linewidth = 1,
    linetype = "solid",
    alpha = 1
  )
)

# A Layer subclass that hands the layer's fully-resolved aesthetic mapping to
# the stat, then defers to ggplot2's own compute_statistic(). The mapping is
# only complete (inherited aes included) at this point in the build, which is
# why it cannot be captured in geom_slice() itself.
#
# ggplot2 >= 3.5.0 supports custom layer classes via layer(layer_class = ...);
# the Layer class itself is not exported, hence the :::.
SliceLayer <- ggproto(
  "SliceLayer",
  ggplot2:::Layer,
  compute_statistic = function(self, data, layout) {
    self$stat_params$mapping <- self$computed_mapping
    ggproto_parent(ggplot2:::Layer, self)$compute_statistic(data, layout)
  }
)


# ---------------------------------------------------------------------------
# User-facing constructor
# ---------------------------------------------------------------------------

#' Display a 2D slice of a linear model
#'
#' `geom_slice()` draws the prediction line of a fitted [lm()] on a ggplot —
#' a 2D *slice* of a possibly high-dimensional model. The predictor mapped to
#' the plot's x-axis varies along the line; every other predictor is fixed,
#' and `geom_slice()` reports how, so it is always clear which slice of the
#' model you are looking at:
#'
#' - Variables named in `predict_vars` are held at your chosen values.
#' - Variables mapped to a grouping aesthetic (e.g. `aes(color = g)`) are
#'   pinned to each group's own value — one line per group.
#' - Facet variables are pinned to each panel's value.
#' - Anything left over is *imputed* (mean for numeric, most common value for
#'   factor/character), with a console message naming the value used.
#'
#' If the model's response is transformed (e.g. `lm(log(y) ~ x)`) but the plot
#' shows raw `y`, predictions are automatically back-transformed to match the
#' y-axis (a message says so). Axis expressions (`aes(log(y))`, `aes(x * x2)`)
#' and transformed scales (`scale_x_log10()`) are also handled.
#'
#' @param model A linear model fitted by [lm()].
#' @param n Number of prediction points along the line (default 100).
#' @param inherit.aes If `TRUE` (default), inherit aesthetics from the
#'   `ggplot()` call.
#' @param predict_vars A named list of values at which to hold predictors not
#'   shown on the plot, such as `predict_vars = list(hp = 110)`. Unlisted
#'   predictors are imputed (with a message).
#' @param back_transform How to map predictions onto the y-axis when the
#'   model's response is transformed. Default `NULL` (and `TRUE`) auto-detects
#'   from the model formula; `FALSE` turns back-transformation off; a
#'   one-argument function (e.g. `exp`) or a name (`"log"`, `"log10"`,
#'   `"log2"`, `"sqrt"`, `"exp"`, `"inverse"`) applies that transformation.
#' @param ... Other arguments passed to the layer, such as fixed aesthetics
#'   (`color = "red"`, `linewidth = 1.2`).
#' @param xaxis Not an argument of `geom_slice()` — the x-axis comes from the
#'   plot's `aes()`. Included only to give a helpful error to `slice_2d()`
#'   users who try it here.
#'
#' @returns A ggplot2 layer that draws the slice.
#'
#' @examples
#' \dontrun{
#' # Hold hp at its mean (reported by a message)
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model)
#'
#' # Choose the slice yourself
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = 110))
#'
#' # One line per group, pinned to each group's value
#' model2 <- lm(mpg ~ disp * factor(cyl), data = mtcars)
#' ggplot(mtcars, aes(disp, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   geom_slice(lm(mpg ~ disp + cyl, data = mtcars))
#'
#' # Transformed response, auto back-transformed to the raw y-axis
#' model3 <- lm(log(mpg) ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model3)
#' }
#'
#' @export
geom_slice <- function(model,
                       n = 100,
                       inherit.aes = TRUE,
                       predict_vars = list(),
                       back_transform = NULL,
                       ...,
                       xaxis = NULL) {
  if (!is.null(xaxis)) {
    slice_abort(
      what = "`xaxis` is not an argument of `geom_slice()`.",
      hint = "Set the x-axis in the plot's aes() instead, such as 'ggplot(your_data, aes(x = disp, y = mpg))'."
    )
  }
  check_slice_model(model)
  check_predict_vars(predict_vars, model)
  back_transform <- check_back_transform(back_transform)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    slice_abort(
      what = "`n` must be a single number of at least 2.",
      hint = "For example, 'n = 100'."
    )
  }

  layer(
    stat = StatSlice,
    geom = GeomSlice,
    position = "identity",
    inherit.aes = inherit.aes,
    show.legend = NA,
    params = list(
      model = model,
      predict_vars = predict_vars,
      n = n,
      back_transform = back_transform,
      ...
    ),
    layer_class = SliceLayer
  )
}
