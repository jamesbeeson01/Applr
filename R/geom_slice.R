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
#   GeomSlice      GeomSmooth with slice-flavored default aesthetics (line,
#                  plus a ribbon when an interval is requested).
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

# Coerce one or more values recovered from the plot (facet layout, aesthetic
# column, or predict_vars) back to the type of the model variable they pin.
coerce_like <- function(value, template, var) {
  if (is.factor(template)) {
    value <- as.character(value)
    bad <- setdiff(value, levels(template))
    if (length(bad) > 0) {
      slice_abort(
        what = paste0("\"", bad[1], "\" is not a level of the model's factor `", var, "`."),
        hint = paste0("Use one of: ", paste0('"', levels(template), '"', collapse = ", "), ".")
      )
    }
    return(factor(value, levels = levels(template)))
  }
  if (is.numeric(template)) {
    coerced <- suppressWarnings(as.numeric(as.character(value)))
    bad <- is.na(coerced) & !is.na(value)
    if (any(bad)) {
      slice_abort(
        what = paste0("Value \"", value[bad][1], "\" for the numeric variable `", var, "` is not a number."),
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

check_slice_model <- function(model, fn = "geom_slice") {
  if (missing(model) || is.null(model)) {
    slice_abort(
      what = paste0(fn, "() needs a fitted model."),
      hint = paste0("Fit one first, such as 'model <- lm(y ~ x, data = your_data)', then call '",
                    fn, "(model)'.")
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
    if (!is.atomic(predict_vars[[var]]) || length(predict_vars[[var]]) < 1) {
      slice_abort(
        what = paste0("`predict_vars` value for `", var, "` must be one or more values."),
        hint = paste0("For example, 'predict_vars = list(", var, " = 1)' or ",
                      "'predict_vars = list(", var, " = c(1, 2, 3))' for one line per value.")
      )
    }
  }
  invisible(predict_vars)
}

# Validate `interval` at construction time; returns the normalized string.
check_slice_interval <- function(interval) {
  choices <- c("none", "confidence", "prediction")
  if (!is.character(interval) || length(interval) != 1 || is.na(interval) ||
      !interval %in% choices) {
    slice_abort(
      what = paste0("`interval` must be one of ",
                    paste0('"', choices, '"', collapse = ", "), "."),
      hint = "For example, 'interval = \"confidence\"'."
    )
  }
  interval
}

# Validate `band` at construction time; returns FALSE, TRUE, or the variable
# name. Whether a named variable can actually band (it must be a model
# predictor the plot doesn't already show) is only knowable once the plot's
# mapping is resolved, so those checks live in resolve_slice_band().
check_slice_band <- function(band, interval) {
  if (isFALSE(band) || is.null(band)) return(FALSE)
  is_name <- is.character(band) && length(band) == 1 && !is.na(band)
  if (!isTRUE(band) && !is_name) {
    slice_abort(
      what = "`band` must be TRUE, FALSE, or the name of one model predictor.",
      hint = "For example, 'band = TRUE' or 'band = \"x2\"'."
    )
  }
  if (!identical(interval, "none")) {
    slice_abort(
      what = "`band` and `interval` cannot be combined in one geom_slice() layer.",
      hint = "Drop 'interval =' to draw the band, or 'band =' to draw the interval ribbon."
    )
  }
  band
}

# Resolve which variable a projection band spans, and between which two
# values. Returns NULL (no band) or list(var =, values = c(lo, hi)).
# A band that cannot be resolved warns and returns NULL — the band is
# skipped but the slice lines still draw.
# With band = TRUE the variable is inferred: the one multi-value predict_vars
# entry if there is one, otherwise the single predictor the plot does not
# already show. The range comes from predict_vars when given, otherwise the
# variable's observed range in the model's data.
resolve_slice_band <- function(band, predict_vars, predictor_vars, x_vars,
                               pinned_vars, raw_data, quiet = FALSE) {
  if (isFALSE(band) || is.null(band)) return(NULL)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")

  # Predictors a band could actually span on this plot, and a hint that names
  # them (or, when there are none, says what to do about it).
  bandable <- setdiff(predictor_vars, c(x_vars, pinned_vars))
  bandable_hint <- if (length(bandable) == 1) {
    paste0("Use 'band = \"", bandable, "\"', or 'band = TRUE' to choose automatically.")
  } else if (length(bandable) > 1) {
    paste0("Use one of ", backticked(bandable), ", such as 'band = \"", bandable[1],
           "\"', or 'band = TRUE' to choose automatically.")
  } else {
    "A band spans a second predictor besides the x-axis variable; add one to the model."
  }

  if (isTRUE(band)) {
    multi <- setdiff(names(predict_vars)[lengths(predict_vars) > 1], x_vars)
    if (length(multi) > 1) {
      slice_warn(
        what = paste0("band = TRUE is ambiguous: several `predict_vars` variables ",
                      "have multiple values (", backticked(multi), "). No band is drawn."),
        hint = paste0("Name the one to span, such as 'band = \"", multi[1], "\"'.")
      )
      return(NULL)
    }
    if (length(multi) == 1) {
      var <- multi
    } else {
      candidates <- setdiff(predictor_vars,
                            c(x_vars, pinned_vars, names(predict_vars)))
      if (length(candidates) == 0) {
        slice_warn(
          what = paste0("band = TRUE, but the model has no variable to span - ",
                        "every predictor is already shown on the plot. No band is drawn."),
          hint = "A band spans a second predictor besides the x-axis variable; add one to the model."
        )
        return(NULL)
      }
      if (length(candidates) > 1) {
        slice_warn(
          what = paste0("band = TRUE is ambiguous: any of ", backticked(candidates),
                        " could be spanned. No band is drawn."),
          hint = paste0("Name the one to span, such as 'band = \"", candidates[1], "\"'.")
        )
        return(NULL)
      }
      var <- candidates
    }
  } else {
    var <- band
    if (!var %in% predictor_vars) {
      slice_warn(
        what = paste0("`band` variable \"", var,
                      "\" is not a predictor in the model. No band is drawn."),
        hint = bandable_hint
      )
      return(NULL)
    }
    if (var %in% x_vars) {
      slice_warn(
        what = paste0("`band` variable `", var,
                      "` is on the x-axis, so it already varies along the line. ",
                      "No band is drawn."),
        hint = bandable_hint
      )
      return(NULL)
    }
    if (var %in% pinned_vars) {
      slice_warn(
        what = paste0("`band` variable `", var, "` is used by the plot's ",
                      "grouping or faceting, so each line already uses its own value. ",
                      "No band is drawn."),
        hint = bandable_hint
      )
      return(NULL)
    }
  }

  if (!is.numeric(raw_data[[var]])) {
    slice_warn(
      what = paste0("`band` variable `", var,
                    "` is not numeric, so it has no range to span. No band is drawn."),
      hint = paste0("Bands span a numeric predictor; for a factor, map it to a ",
                    "grouping aesthetic for one line per level instead.")
    )
    return(NULL)
  }

  if (!is.null(predict_vars[[var]])) {
    values <- range(coerce_like(predict_vars[[var]], raw_data[[var]], var))
  } else {
    values <- range(raw_data[[var]], na.rm = TRUE)
    if (!quiet) {
      slice_inform(
        what = paste0("Band range for `", var, "` not specified - used the min/max data range: ",
                      format_value(values[1]), " to ", format_value(values[2]), "."),
        hint = paste0("To choose the range, use 'predict_vars = list(", var, " = c(",
                      format_value(values[1]), ", ", format_value(values[2]), "))'.")
      )
    }
  }
  list(var = var, values = values)
}

# Error if the data on the plot is visibly different from the data the model
# was fitted to (a slice through one model drawn over another dataset is
# meaningless, but looks plausible). Only *positive* mismatches abort: when the
# plot data shares none of the model's columns, or the model's data cannot be
# recovered, later stages give more specific errors.
check_slice_plot_data <- function(model, plot_data, model_name = "model") {
  if (!is.data.frame(plot_data) || nrow(plot_data) == 0) return(invisible())
  model_data <- tryCatch(slice_model_frame(model), error = function(e) NULL)
  if (is.null(model_data)) return(invisible())
  shared <- intersect(names(model_data), names(plot_data))
  if (length(shared) == 0) return(invisible())

  column_equal <- function(a, b) {
    if (is.numeric(a) && is.numeric(b)) {
      isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE))
    } else {
      identical(as.character(a), as.character(b))
    }
  }
  frames_equal <- function(a, b) {
    all(vapply(shared, function(v) column_equal(a[[v]], b[[v]]), logical(1)))
  }
  sort_rows <- function(d) d[do.call(order, unname(as.list(d))), , drop = FALSE]

  model_cols <- as.data.frame(model_data)[shared]
  plot_cols  <- as.data.frame(plot_data)[shared]
  same <- nrow(model_cols) == nrow(plot_cols) &&
    (frames_equal(model_cols, plot_cols) ||
       # the same rows in a different order are still the same data
       frames_equal(sort_rows(model_cols), sort_rows(plot_cols)))
  if (!same) {
    slice_abort(
      what = paste0("The data on the plot is not the data `", model_name, "` was fitted to."),
      hint = paste0("Fit the model to the plotted data, such as ",
                    "'model <- lm(y ~ x, data = your_data)', ",
                    "or plot the data the model was fitted to.")
    )
  }
  invisible()
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

  # --- projection band: one variable spans a range instead of being held ---
  band <- resolve_slice_band(params$band, predict_vars, predictor_vars, x_vars,
                             c(unlist(group_aes), facet_vars), raw_data)

  # --- held variables: everything the plot does not show ---
  held_vars <- setdiff(predictor_vars, c(x_vars, unlist(group_aes), facet_vars,
                                         if (!is.null(band)) band$var))
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
    band = band,
    y_fn = resolve_y_fn(model, mapping$y, params$back_transform)
  )
}

# Reconcile the spec's per-group pins against how ggplot actually grouped the
# data. A grouping aesthetic can only pin its predictor if the predictor is
# constant within each group; a continuous scale (numeric mapped to colour,
# size, ...) puts many values in one group, making data[[aes]][1] arbitrary.
# Only the built data can tell: `colour = g` and `colour = factor(g)` name the
# same predictor but group differently. Broken pins fall back to being held
# constant, like any predictor the plot does not show.
resolve_group_pins <- function(spec, data) {
  for (aes_name in names(spec$group_aes)) {
    col <- data[[aes_name]]
    if (is.null(col)) next
    grouped_cleanly <- all(vapply(split(col, data$group),
                                  function(x) length(unique(x)) == 1L, logical(1)))
    if (grouped_cleanly) next

    var <- spec$group_aes[[aes_name]]
    spec$group_aes[[aes_name]] <- NULL
    # ggplot standardizes aes names to British spelling; messages use American
    shown <- if (aes_name == "colour") "color" else aes_name
    slice_warn(
      what = paste0("`", shown, " = ", var, "` is on a continuous scale, so it cannot ",
                    "pin `", var, "` per group; it will be held constant instead."),
      hint = paste0("For one line per value, use 'aes(", shown, " = factor(", var, "))'.")
    )
    spec$held[[var]] <- impute_value(spec$raw_data[[var]], var)
  }
  spec
}

# Build the prediction line(s) for one group, following the layer's slice
# spec. Held variables with several values (predict_vars = list(x2 = c(1, 2)))
# yield one line per combination of values, each with its own group id.
compute_slice_group <- function(data, scales, spec, n, interval = "none") {
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
  } else {
    # The x-axis is an expression of several predictors: predict at the
    # model's own data points (filtered to this group), and place each
    # prediction at the row's x-axis expression value. Held variables are
    # never part of the x expression, so overwriting them per combination
    # below does not move the points along x.
    rows <- spec$raw_data
    for (var in names(pinned)) {
      keep <- !is.na(rows[[var]]) & rows[[var]] == pinned[[var]]
      if (any(keep)) rows <- rows[keep, , drop = FALSE]
    }
    newdata <- rows
    x_panel <- x_trans$transform(rlang::eval_tidy(spec$x_quo, data = rows))
  }

  ord <- order(x_panel)
  extra <- data[1, setdiff(names(data), c("x", "y")), drop = FALSE]

  # One slice per combination of held values (usually a single combination).
  combos <- expand.grid(spec$held, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  if (nrow(combos) == 0) combos <- data.frame(row.names = 1)

  safe_predict <- function(newdata) {
    tryCatch(
      predict(spec$model, newdata = newdata, interval = interval),
      error = function(e) {
        slice_abort(
          what = paste0("predict() failed for this slice: ", conditionMessage(e)),
          hint = "Check that `predict_vars` values match the model's variable types."
        )
      }
    )
  }

  lines <- lapply(seq_len(nrow(combos)), function(i) {
    for (var in names(combos)) newdata[[var]] <- combos[[var]][i]
    if (!is.null(spec$band)) {
      # A projection band: predict at both ends of the banded variable's
      # range. pmin/pmax keep the ribbon upright when the band's effect (or
      # y_fn) is decreasing.
      newdata[[spec$band$var]] <- spec$band$values[1]
      lo <- y_trans$transform(spec$y_fn(safe_predict(newdata)))
      newdata[[spec$band$var]] <- spec$band$values[2]
      hi <- y_trans$transform(spec$y_fn(safe_predict(newdata)))
      out <- data.frame(x = x_panel[ord], y = ((lo + hi) / 2)[ord],
                        ymin = pmin(lo, hi)[ord], ymax = pmax(lo, hi)[ord],
                        extra, row.names = NULL)
      if (nrow(combos) > 1) out$group <- data$group[1] * nrow(combos) + (i - 1)
      return(out)
    }
    predictions <- safe_predict(newdata)
    if (is.matrix(predictions)) {
      # interval = "confidence"/"prediction": fit, lwr, upr columns. pmin/pmax
      # keep the ribbon upright when y_fn is decreasing (e.g. inverse).
      fit <- y_trans$transform(spec$y_fn(predictions[, "fit"]))
      lo  <- y_trans$transform(spec$y_fn(predictions[, "lwr"]))
      hi  <- y_trans$transform(spec$y_fn(predictions[, "upr"]))
      out <- data.frame(x = x_panel[ord], y = fit[ord],
                        ymin = pmin(lo, hi)[ord], ymax = pmax(lo, hi)[ord],
                        extra, row.names = NULL)
    } else {
      y_panel <- y_trans$transform(spec$y_fn(predictions))
      out <- data.frame(x = x_panel[ord], y = y_panel[ord], extra, row.names = NULL)
    }
    # Separate group ids keep the combos as distinct lines; scaling by the
    # number of combos keeps ids unique across the layer's original groups.
    if (nrow(combos) > 1) out$group <- data$group[1] * nrow(combos) + (i - 1)
    out
  })
  do.call(rbind, lines)
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
  extra_params = c("na.rm", "mapping", "model_name"),

  # Resolve the slice plan once per layer (imputation messages fire once here,
  # not once per group), then let ggplot2's standard machinery split the data
  # by panel and group.
  compute_layer = function(self, data, params, layout) {
    # resolve_group_pins() needs the grouped data to tell a real per-group pin
    # from a numeric aesthetic ggplot left as a continuous scale.
    params$slice_spec <- resolve_group_pins(build_slice_spec(params, layout), data)
    ggproto_parent(Stat, self)$compute_layer(data, params, layout)
  },

  compute_group = function(data, scales, model, predict_vars = list(),
                           back_transform = NULL, n = 100, interval = "none",
                           band = FALSE, mapping = NULL, slice_spec = NULL,
                           na.rm = FALSE) {
    compute_slice_group(data, scales, slice_spec, n, interval)
  }
)

#' GeomSlice
#'
#' The geom behind [geom_slice()]: [ggplot2::GeomSmooth] with slice-flavored
#' default aesthetics. Like `geom_smooth()`, it draws a line plus — when the
#' stat supplies `ymin`/`ymax` (i.e. `interval = "confidence"` or
#' `"prediction"`) — a ribbon; `alpha` styles the ribbon, not the line.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{GeomSmooth}.
#'
#' @export
GeomSlice <- ggproto(
  "GeomSlice",
  GeomSmooth,
  default_aes = aes(
    color = "skyblue",
    fill = "skyblue",
    linewidth = 1,
    linetype = "solid",
    weight = 1,
    alpha = 0.4
  )
)

#' GeomSliceBand
#'
#' The geom behind [geom_slice()] when `band` is requested: a translucent
#' ribbon between the two edge slices, with each edge drawn as an ordinary
#' slice line. Like [GeomSlice], `alpha` styles the ribbon, not the lines.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{GeomSlice}.
#'
#' @export
GeomSliceBand <- ggproto(
  "GeomSliceBand",
  GeomSlice,
  draw_group = function(self, data, panel_params, coord, lineend = "butt",
                        linejoin = "round", linemitre = 10, se = TRUE,
                        flipped_aes = FALSE, na.rm = FALSE) {
    # No ymin/ymax means the band could not be resolved (the stat already
    # warned); draw the slice line alone.
    if (is.null(data$ymin) || all(is.na(data$ymin))) {
      return(ggproto_parent(GeomSlice, self)$draw_group(
        data, panel_params, coord, lineend = lineend, linejoin = linejoin,
        linemitre = linemitre, se = FALSE, flipped_aes = flipped_aes
      ))
    }
    ribbon <- transform(data, colour = NA)
    # A band is one object in one color: when fill was not set (still the
    # default), the ribbon takes the edge lines' colour, so a grouping
    # aesthetic mapped to colour colors the whole band.
    default_fill <- self$default_aes$fill
    ribbon$fill <- ifelse(ribbon$fill == default_fill, data$colour, ribbon$fill)
    edges <- lapply(c("ymin", "ymax"), function(edge) {
      line <- data
      line$y <- data[[edge]]
      line$alpha <- NA
      GeomLine$draw_panel(line, panel_params, coord, lineend = lineend)
    })
    grid::grobTree(
      GeomRibbon$draw_group(ribbon, panel_params, coord,
                            flipped_aes = flipped_aes, na.rm = na.rm),
      edges[[1]], edges[[2]]
    )
  }
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

# Adding the layer to a plot is the first moment both the model and the plot's
# data are in hand, and — unlike the build steps, which ggplot2 wraps in
# "Problem while ..." chains — an error here reaches the user directly.
#' @export
#' @noRd
ggplot_add.SliceLayer <- function(object, plot, ...) {
  check_slice_plot_data(object$stat_params$model, plot$data,
                        object$stat_params$model_name %||% "model")
  NextMethod()
}


# ---------------------------------------------------------------------------
# User-facing constructor
# ---------------------------------------------------------------------------

#' Display a 2D slice of a linear model
#'
#' `geom_slice()` draws the prediction line of a fitted [lm()] on a ggplot —
#' a 2D *slice* of a possibly high-dimensional model. It looks like
#' [ggplot2::geom_smooth()], but where `geom_smooth()` fits its own model to
#' the plotted data, `geom_slice()` draws *your* model. The predictor mapped to
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
#'   predictors are imputed (with a message). Giving a variable several values
#'   draws one line per value, and several multi-value variables are crossed:
#'   `predict_vars = list(x2 = c(1, 2, 3), x3 = c(1, 4))` draws 6 lines.
#' @param interval Draw a ribbon around the line: `"none"` (default), or
#'   `"confidence"` / `"prediction"` for the corresponding [predict.lm()]
#'   interval. Cannot be combined with `band`.
#' @param band Draw a *projection band* — two edge slices with a translucent
#'   ribbon between them — instead of a single line. `band = "variable"` spans
#'   that predictor: between the values you gave in `predict_vars` (e.g.
#'   `predict_vars = list(x2 = c(1, 4))`), or its observed data range when
#'   `predict_vars` leaves it out. `band = TRUE` infers the variable: the one
#'   multi-value `predict_vars` entry, or the single predictor the plot does
#'   not otherwise show. Default `FALSE`.
#' @param back_transform How to map predictions onto the y-axis when the
#'   model's response is transformed. Default `NULL` (and `TRUE`) auto-detects
#'   from the model formula; `FALSE` turns back-transformation off; a
#'   one-argument function (e.g. `exp`) or a name (`"log"`, `"log10"`,
#'   `"log2"`, `"sqrt"`, `"exp"`, `"inverse"`) applies that transformation.
#' @param ... Other arguments passed to the layer, such as fixed aesthetics
#'   (`color = "red"`, `linewidth = 1.2`).
#' @param x_axis,xaxis Not arguments of `geom_slice()` — the x-axis comes from
#'   the plot's `aes()`. Included only to give a helpful error to `slice_2d()`
#'   users who try them here.
#'
#' @returns A ggplot2 layer that draws the slice.
#'
#' @seealso
#' - [geom_slice_text()] to label each line with the values that produced it.
#' - [geom_slice_subtitle()] / [geom_slice_caption()] to describe the slice
#'   (model equation, held values) in the plot's subtitle or caption.
#' - [autoplot.lm()] for a complete data-plus-slice plot in one call.
#' - [ggplot2::geom_smooth()], which this layer resembles, except that it
#'   draws a model you fitted rather than fitting its own.
#'
#' @examples
#' library(ggplot2)
#'
#' # Basic use, like geom_smooth() but drawing *your* model. hp is not on
#' # the plot, so it is held at its mean (a console message says so).
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
#' # Several values draw one line per value (label them with
#' # geom_slice_text()); several multi-value variables are crossed
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = c(66, 150, 335)))
#'
#' # Confidence or prediction ribbon around the line
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = 110), interval = "confidence")
#'
#' # A grouping aesthetic pins its predictor to each group's own value:
#' # one line per cylinder count, each with its own slope
#' model2 <- lm(mpg ~ disp * cyl, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   geom_slice(model2)
#'
#' # Facet variables pin per panel the same way
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model2) +
#'   facet_wrap(~ cyl)
#'
#' # A transformed response is back-transformed automatically: the model
#' # predicts log(mpg), the line appears in raw mpg units (a message says so)
#' model3 <- lm(log(mpg) ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model3)
#'
#' # ... or control the mapping yourself with back_transform
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model3, back_transform = exp)
#'
#' # A projection band spanning hp between two values, instead of a line
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = c(66, 335)), band = "hp")
#'
#' # n controls how many prediction points make up the line
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = 110), n = 10)
#'
#' @export
geom_slice <- function(model,
                       n = 100,
                       inherit.aes = TRUE,
                       predict_vars = list(),
                       back_transform = NULL,
                       interval = "none",
                       band = FALSE,
                       ...,
                       x_axis = NULL,
                       xaxis = NULL) {
  if (!is.null(x_axis) || !is.null(xaxis)) {
    slice_abort(
      what = "`x_axis` is not an argument of `geom_slice()`.",
      hint = "Set the x-axis in the plot's aes() instead, such as 'ggplot(your_data, aes(x = disp, y = mpg))'."
    )
  }
  check_slice_model(model)
  # A stray aes() is a common mistake, rarely assigned to a specific parameter
  if (inherits(n, "uneval") || inherits(inherit.aes, "uneval") ||
      inherits(back_transform, "uneval") || inherits(interval, "uneval")) {
    slice_abort(
      what = "geom_slice() does not take an aesthetic mapping as an argument.",
      hint = "Put the mapping in the plot instead: 'ggplot(data, aes(...)) + geom_slice(model)'."
    )
  }
  check_predict_vars(predict_vars, model)
  back_transform <- check_back_transform(back_transform)
  interval <- check_slice_interval(interval)
  band <- check_slice_band(band, interval)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    slice_abort(
      what = "`n` must be a single number of at least 2.",
      hint = "For example, 'n = 100'."
    )
  }
  # How the user referred to the model, for messages about it ("model" if the
  # call was too complex to name it).
  model_expr <- substitute(model)
  model_name <- if (is.symbol(model_expr)) as.character(model_expr) else "model"

  layer(
    stat = StatSlice,
    geom = if (isFALSE(band)) GeomSlice else GeomSliceBand,
    position = "identity",
    inherit.aes = inherit.aes,
    show.legend = NA,
    params = list(
      model = model,
      model_name = model_name,
      predict_vars = predict_vars,
      n = n,
      back_transform = back_transform,
      interval = interval,
      band = band,
      # GeomSmooth only draws the ribbon when its `se` param says so
      se = !identical(interval, "none") || !isFALSE(band),
      ...
    ),
    layer_class = SliceLayer
  )
}
