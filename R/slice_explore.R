# slice_explore() — an interactive, slider-driven exploration of an lm().
#
# Architecture:
#
#   slice_explore()  validates input, captures the `sliders` expression, and
#                    hands everything to explore_spec(); the returned spec is
#                    rendered by explore_widget().
#   explore_spec()   the computation. It builds a REAL ggplot — the same
#                    scatter + geom_slice() that autoplot.lm() draws — with
#                    each slider variable passed to geom_slice() as a
#                    multi-value predict_vars grid. geom_slice() already
#                    crosses multi-value held variables into one prediction
#                    line per combination, so a single ggplot_build() computes
#                    every curve the sliders can show, with geom_slice's own
#                    imputation, back-transformation, grouping, and messages.
#                    The built layer data carries `.held_<var>` columns (see
#                    compute_slice_group()) identifying which combination each
#                    curve belongs to; explore_spec() indexes the curves by
#                    slider position and returns a deterministic list — the
#                    testable core of the feature.
#   explore_widget() display only. A plotly widget with the scatter, the
#                    initial curve(s), one plotly slider per variable, and a
#                    small htmlwidgets::onRender() script that swaps in the
#                    precomputed y arrays as sliders move (a Plotly.restyle of
#                    ~100 numbers, so dragging feels continuous).
#
# Because every curve is computed by geom_slice() through a normal
# ggplot_build(), any change to geom_slice's behavior — imputation rules,
# back-transform detection, new interval types — flows into slice_explore()
# with no second implementation to edit. The JavaScript never predicts
# anything; it only chooses which precomputed curve to show.


# ---------------------------------------------------------------------------
# Slider resolution
# ---------------------------------------------------------------------------

# Format a slider value for its step label / start message: numbers like
# format_value() but without quotes on strings (labels, not code).
fmt_slider <- function(value) {
  if (is.numeric(value)) format(signif(value, 4)) else as.character(value)
}

# Parse the `sliders` argument from its quosure. Returns NULL for TRUE
# ("sliders on everything held"), or a list of list(var =, discrete =)
# entries — `factor(x)` marks a numeric variable as discrete (steps at its
# observed unique values).
explore_slider_vars <- function(sliders_quo) {
  val <- tryCatch(rlang::eval_tidy(sliders_quo), error = function(e) NULL)
  # autoplot.lm() forwards the user's quosure as a value; unwrap it
  if (rlang::is_quosure(val)) return(explore_slider_vars(val))
  if (isTRUE(val)) return(NULL)
  if (is.character(val)) {
    return(lapply(val, function(v) list(var = v, discrete = FALSE)))
  }
  expr <- rlang::quo_get_expr(sliders_quo)
  if (isFALSE(val) || is.null(expr)) {
    slice_abort(
      what = "slice_explore() needs at least one slider.",
      hint = "Use 'sliders = TRUE' for all unshown predictors, or autoplot(model) for the static plot."
    )
  }
  parse_one <- function(e) {
    if (is.name(e)) {
      return(list(list(var = as.character(e), discrete = FALSE)))
    }
    if (is.character(e)) {
      return(lapply(e, function(v) list(var = v, discrete = FALSE)))
    }
    if (is.call(e)) {
      head <- expr_text(e[[1]])
      if (head == "c") {
        return(unlist(lapply(as.list(e)[-1], parse_one), recursive = FALSE))
      }
      if (head == "factor" && length(e) == 2 &&
          (is.name(e[[2]]) || is.character(e[[2]]))) {
        return(list(list(var = as.character(e[[2]]), discrete = TRUE)))
      }
    }
    slice_abort(
      what = paste0("`sliders` could not be understood: `", expr_text(e), "`."),
      hint = paste0("Use TRUE, variable names such as 'sliders = c(disp, cyl)', ",
                    "or 'factor(cyl)' for steps at the observed values.")
    )
  }
  vars <- parse_one(expr)
  vars[!duplicated(vapply(vars, `[[`, "", "var"))]
}

# Normalize `slider_breaks` to a named list keyed by slider variable.
# A bare vector is allowed when there is exactly one slider.
check_slider_breaks <- function(slider_breaks, slider_vars) {
  if (is.null(slider_breaks)) return(list())
  is_named_list <- is.list(slider_breaks) && !is.null(names(slider_breaks)) &&
    all(names(slider_breaks) != "")
  if (!is_named_list) {
    if (is.atomic(slider_breaks) && length(slider_vars) == 1) {
      slider_breaks <- setNames(list(slider_breaks), slider_vars[1])
    } else {
      slice_abort(
        what = "`slider_breaks` must be a named list of variable = values pairs.",
        hint = paste0("For example, 'slider_breaks = list(", slider_vars[1],
                      " = c(1, 2, 3))'.")
      )
    }
  }
  bad <- setdiff(names(slider_breaks), slider_vars)
  if (length(bad) > 0) {
    slice_abort(
      what = paste0("`slider_breaks` variable \"", bad[1],
                    "\" has no slider."),
      hint = paste0("The slider variables are ",
                    paste0("`", slider_vars, "`", collapse = ", "), ".")
    )
  }
  for (var in names(slider_breaks)) {
    b <- slider_breaks[[var]]
    if (is.character(b) && length(b) == 1 && tolower(b) == "continuous") {
      slice_abort(
        what = paste0("slider_breaks = \"continuous\" is not needed: the `",
                      var, "` slider is continuous by default."),
        hint = paste0("Omit the breaks for a smooth slider, or give values such as ",
                      "'slider_breaks = list(", var, " = c(1, 2, 3))' for fixed steps.")
      )
    }
    if (!is.atomic(b) || length(b) < 2) {
      slice_abort(
        what = paste0("`slider_breaks` for `", var, "` needs at least two values."),
        hint = paste0("For example, 'slider_breaks = list(", var, " = c(1, 2, 3))'.")
      )
    }
  }
  slider_breaks
}

# Normalize `slider_steps` to a named integer vector keyed by slider variable.
# A bare number applies to every continuous slider.
check_slider_steps <- function(slider_steps, slider_vars) {
  if (is.null(slider_steps)) return(integer(0))
  if (is.list(slider_steps)) slider_steps <- unlist(slider_steps)
  if (!is.numeric(slider_steps) || any(is.na(slider_steps)) ||
      any(slider_steps < 2)) {
    slice_abort(
      what = "`slider_steps` must be whole numbers of at least 2.",
      hint = "For example, 'slider_steps = 15', or 'slider_steps = list(hp = 15)'."
    )
  }
  if (is.null(names(slider_steps))) {
    if (length(slider_steps) != 1) {
      slice_abort(
        what = "`slider_steps` must be a single number or a named list.",
        hint = paste0("For example, 'slider_steps = list(", slider_vars[1],
                      " = 15)'.")
      )
    }
    slider_steps <- setNames(rep(slider_steps, length(slider_vars)), slider_vars)
  }
  bad <- setdiff(names(slider_steps), slider_vars)
  if (length(bad) > 0) {
    slice_abort(
      what = paste0("`slider_steps` variable \"", bad[1], "\" has no slider."),
      hint = paste0("The slider variables are ",
                    paste0("`", slider_vars, "`", collapse = ", "), ".")
    )
  }
  as.integer(round(slider_steps))
}

# Build one slider's value grid and starting position. The start mirrors
# geom_slice()'s imputation (mean / most common value): with an automatic
# grid the exact default replaces the nearest grid point, so the initial view
# is identical to the static autoplot(); with user breaks the nearest break
# is used.
slider_grid <- function(var, column, breaks = NULL, steps = NULL,
                        discrete = FALSE) {
  discrete <- discrete || is.factor(column) || is.character(column)
  default <- suppressMessages(impute_value(column, var))
  if (!is.null(breaks)) {
    values <- coerce_like(breaks, column, var)
    values <- if (is.numeric(values)) sort(unique(values)) else unique(values)
    if (is.factor(values)) values <- as.character(values)
  } else if (discrete) {
    values <- if (is.factor(column)) {
      levels(column)
    } else {
      sort(unique(column[!is.na(column)]))
    }
    if (length(values) < 2) {
      slice_abort(
        what = paste0("A slider for `", var, "` needs at least two values, but it only has ",
                      length(values), "."),
        hint = "Drop it from `sliders`, or hold it with 'predict_vars ='."
      )
    }
  } else {
    rng <- range(column, na.rm = TRUE)
    if (rng[1] == rng[2]) {
      slice_abort(
        what = paste0("A slider for `", var, "` needs a range of values, but it is constant."),
        hint = "Drop it from `sliders`, or hold it with 'predict_vars ='."
      )
    }
    values <- seq(rng[1], rng[2], length.out = steps)
    values[which.min(abs(values - as.numeric(default)))] <- as.numeric(default)
  }
  init <- if (is.numeric(values)) {
    which.min(abs(values - as.numeric(default)))
  } else {
    m <- match(as.character(default), as.character(values))
    if (is.na(m)) 1L else m
  }
  list(var = var, values = values,
       labels = vapply(values, fmt_slider, character(1)),
       init = init - 1L,  # 0-based, like plotly's `active`
       discrete = discrete || !is.null(breaks))
}


# ---------------------------------------------------------------------------
# The spec: everything the widget shows, computed by geom_slice()
# ---------------------------------------------------------------------------

# Compute the full exploration spec. This is the deterministic, console-
# testable core of slice_explore(): it returns plain data (slider grids and
# every precomputed curve), no htmlwidget. `sliders_quo` is a quosure; `...`
# is forwarded to geom_slice().
explore_spec <- function(model, sliders_quo, slider_breaks = NULL,
                         slider_steps = NULL, mapping = NULL, data = NULL,
                         x_axis = NULL, ...) {
  check_slice_model(model, fn = "slice_explore")
  frame <- resolve_autoplot_frame(model, x_axis, fn = "slice_explore")
  dots <- list(...)
  user_pv <- dots$predict_vars %||% list()
  if (length(user_pv) > 0) check_predict_vars(user_pv, model)

  if (!is.null(data) && !is.data.frame(data)) {
    slice_abort(
      what = "`data` must be a data frame.",
      hint = "Pass the data to plot the scatter from, such as 'data = your_data'."
    )
  }
  if (!is.null(mapping) && !inherits(mapping, "uneval")) {
    slice_abort(
      what = "`mapping` must be created by aes().",
      hint = "For example, 'mapping = aes(color = cyl)'."
    )
  }

  # The plot's mapping, exactly as autoplot.lm() builds it: auto axes,
  # user entries override / extend.
  plot_mapping <- aes(x = !!as.name(frame$x_axis), y = !!as.name(frame$response))
  if (!is.null(mapping)) {
    plot_mapping[names(mapping)] <- mapping
  }
  shown <- setdiff(names(plot_mapping), c("x", "y", "colour"))
  if (length(shown) > 0) {
    slice_warn(
      what = paste0("slice_explore() only displays the color aesthetic; `",
                    shown[1], "` still pins its variable per group but is not shown."),
      hint = "Map the variable to color instead, such as 'mapping = aes(color = g)'."
    )
  }

  # What the plot already shows; only the rest can slide.
  x_vars <- intersect(all.vars(rlang::quo_get_expr(plot_mapping$x)),
                      frame$predictors)
  pinned_vars <- slice_text_group_vars(plot_mapping, model)
  backticked <- function(vars) paste0("`", vars, "`", collapse = ", ")
  candidates <- setdiff(frame$predictors, c(x_vars, pinned_vars, names(user_pv)))

  parsed <- explore_slider_vars(sliders_quo)
  if (is.null(parsed)) {  # sliders = TRUE
    if (length(candidates) == 0) {
      slice_abort(
        what = "sliders = TRUE, but every predictor is already shown on the plot - there is nothing to slide.",
        hint = "Sliders drive the predictors the plot does not show; add one to the model, or free one up."
      )
    }
    parsed <- lapply(candidates, function(v) list(var = v, discrete = FALSE))
  }
  for (s in parsed) {
    if (!s$var %in% frame$predictors) {
      slice_abort(
        what = paste0("`sliders` variable \"", s$var, "\" not found in the model."),
        hint = paste0("The model's predictors are ", backticked(frame$predictors), ".")
      )
    }
    if (s$var %in% x_vars) {
      slice_abort(
        what = paste0("`sliders` variable `", s$var,
                      "` is on the x-axis, so it already varies along the line."),
        hint = if (length(candidates) > 0) {
          paste0("Slide a predictor the plot does not show: ", backticked(candidates), ".")
        }
      )
    }
    if (s$var %in% pinned_vars) {
      slice_abort(
        what = paste0("`sliders` variable `", s$var,
                      "` is pinned per group by the plot's mapping."),
        hint = if (length(candidates) > 0) {
          paste0("Slide a predictor the plot does not show: ", backticked(candidates), ".")
        }
      )
    }
    if (s$var %in% names(user_pv)) {
      slice_abort(
        what = paste0("`sliders` variable `", s$var,
                      "` is already held by `predict_vars`."),
        hint = paste0("Drop it from 'predict_vars' to slide it, or from 'sliders' to hold it.")
      )
    }
  }
  slider_vars <- vapply(parsed, `[[`, "", "var")

  slider_breaks <- check_slider_breaks(slider_breaks, slider_vars)
  slider_steps <- check_slider_steps(slider_steps, slider_vars)

  # Two passes: fixed-size sliders (breaks / discrete / explicit steps) first,
  # then the automatic step count for the rest from the remaining curve
  # budget, so several sliders stay light enough to precompute.
  sizes_known <- 1
  n_auto <- 0
  for (s in parsed) {
    column <- frame$data[[s$var]]
    if (!is.null(slider_breaks[[s$var]])) {
      sizes_known <- sizes_known * length(unique(slider_breaks[[s$var]]))
    } else if (s$discrete || is.factor(column) || is.character(column)) {
      sizes_known <- sizes_known * max(2, length(unique(column[!is.na(column)])))
    } else if (!is.na(slider_steps[s$var])) {
      sizes_known <- sizes_known * slider_steps[s$var]
    } else {
      n_auto <- n_auto + 1
    }
  }
  auto_steps <- if (n_auto > 0) {
    budget <- max(60, floor(1400 / sizes_known))
    max(5L, min(41L, as.integer(floor(budget^(1 / n_auto)))))
  } else {
    0L
  }

  sliders <- lapply(parsed, function(s) {
    steps <- if (!is.na(slider_steps[s$var])) slider_steps[[s$var]] else auto_steps
    slider_grid(s$var, frame$data[[s$var]],
                breaks = slider_breaks[[s$var]], steps = steps,
                discrete = s$discrete)
  })
  sizes <- vapply(sliders, function(s) length(s$values), integer(1))
  ncombos <- prod(sizes)
  total_curves <- ncombos * prod(pmax(1, lengths(user_pv)))
  if (total_curves > 5000) {
    slice_abort(
      what = paste0("These sliders need ", format(total_curves, big.mark = ","),
                    " precomputed slices, which is too many to explore smoothly."),
      hint = paste0("Reduce the combinations with 'slider_steps = 10', ",
                    "'slider_breaks =', or fewer `sliders` variables.")
    )
  }

  slice_inform(
    what = paste0("Sliders: ",
                  paste(vapply(sliders, function(s) {
                    paste0("`", s$var, "` starting at ",
                           format_value(s$values[s$init + 1]))
                  }, character(1)), collapse = "; "), "."),
    hint = paste0("To choose the slider values, use 'slider_breaks = list(",
                  sliders[[1]]$var, " = c(...))'.")
  )

  # The real ggplot: geom_slice() computes every curve in one build. Slider
  # grids ride in as multi-value predict_vars, which geom_slice() crosses
  # into one line per combination (and tags with .held_ columns).
  dots$predict_vars <- c(user_pv, setNames(lapply(sliders, `[[`, "values"),
                                           slider_vars))
  p <- ggplot(if (is.null(data)) frame$data else data, plot_mapping) +
    geom_point() +
    do.call(geom_slice, c(list(model), dots))
  built <- ggplot_build(p)

  slice_idx <- which(vapply(p$layers, function(l) inherits(l$stat, "StatSlice"),
                            logical(1)))[1]
  ldat <- built$data[[slice_idx]]
  pdat <- built$data[[1]]

  # Index every curve point by its slider combination: 0-based row-major over
  # the sliders in order (first slider slowest), matching the JS combiner.
  combo <- rep(0, nrow(ldat))
  for (k in seq_along(sliders)) {
    col <- ldat[[paste0(".held_", slider_vars[k])]]
    if (is.null(col)) {
      slice_abort(
        what = paste0("Internal error: geom_slice() did not report held values for `",
                      slider_vars[k], "`."),
        hint = "Please report this at https://github.com/saundersg/Applr/issues."
      )
    }
    values <- sliders[[k]]$values
    idx <- if (is.numeric(values)) {
      vapply(as.numeric(col), function(v) which.min(abs(v - values)),
             integer(1)) - 1L
    } else {
      match(as.character(col), as.character(values)) - 1L
    }
    combo <- combo * length(values) + idx
  }

  # One display curve per combination of everything EXCEPT the sliders:
  # panel, aesthetics (a color group per pinned level), and any multi-value
  # predict_vars the user held. Each display curve owns `ncombos` y arrays.
  key_cols <- c(intersect(c("PANEL", "colour", "fill", "linetype", "linewidth",
                            "alpha"), names(ldat)),
                setdiff(grep("^\\.held_", names(ldat), value = TRUE),
                        paste0(".held_", slider_vars)))
  key <- do.call(interaction,
                 c(lapply(key_cols, function(cn) as.character(ldat[[cn]])),
                   drop = TRUE, lex.order = TRUE))

  has_ribbon <- all(c("ymin", "ymax") %in% names(ldat)) &&
    !all(is.na(ldat$ymin))
  ribbon <- if (!has_ribbon) {
    "none"
  } else if (isFALSE(dots$band %||% FALSE)) {
    "interval"
  } else {
    "band"
  }

  curves <- lapply(levels(key), function(lev) {
    rows <- ldat[key == lev, , drop = FALSE]
    parts <- split(rows, combo[key == lev])
    if (length(parts) != ncombos ||
        length(unique(vapply(parts, nrow, integer(1)))) != 1) {
      slice_abort(
        what = "Internal error: the precomputed slices do not line up with the slider grid.",
        hint = "Please report this at https://github.com/saundersg/Applr/issues."
      )
    }
    first <- parts[[1]]
    out <- list(
      x = first$x,
      colour = first$colour[1],
      linewidth = first$linewidth[1] %||% 1,
      alpha = if (is.na(first$alpha[1])) 0.4 else first$alpha[1],
      y = lapply(parts, function(d) signif(d$y, 7))
    )
    if (has_ribbon) {
      out$ymin <- lapply(parts, function(d) signif(d$ymin, 7))
      out$ymax <- lapply(parts, function(d) signif(d$ymax, 7))
    }
    out
  })

  # Scatter points, one trace per color group so the legend matches the
  # ggplot; group values come from evaluating the color mapping on the
  # plot's data, colors from the built points.
  plot_data <- if (is.null(data)) frame$data else data
  points <- if (!is.null(plot_mapping$colour)) {
    values <- as.character(rlang::eval_tidy(plot_mapping$colour,
                                            data = plot_data))
    lapply(split(seq_len(nrow(pdat)), values[seq_len(nrow(pdat))]),
           function(i) list(name = values[i[1]], x = pdat$x[i], y = pdat$y[i],
                            colour = pdat$colour[i[1]]))
  } else {
    list(list(name = "data", x = pdat$x, y = pdat$y, colour = pdat$colour[1]))
  }

  # Fixed axis ranges over everything any slider position can show, so the
  # plot does not rescale while dragging.
  all_y <- c(pdat$y, unlist(lapply(curves, function(cv) {
    c(unlist(cv$y), unlist(cv$ymin), unlist(cv$ymax))
  })))
  all_x <- c(pdat$x, unlist(lapply(curves, `[[`, "x")))
  pad <- function(r) r + c(-1, 1) * 0.05 * diff(r)

  structure(
    list(
      model = model,
      equation = lm_equation(model),
      x_lab = frame$x_axis,
      y_lab = frame$response,
      x_range = pad(range(all_x, na.rm = TRUE)),
      y_range = pad(range(all_y, na.rm = TRUE)),
      sliders = sliders,
      sizes = sizes,
      ncombos = ncombos,
      ribbon = ribbon,
      curves = curves,
      points = points,
      legend = !is.null(plot_mapping$colour)
    ),
    class = "explore_spec"
  )
}


# ---------------------------------------------------------------------------
# The widget: plotly display of a spec
# ---------------------------------------------------------------------------

# "#RRGGBB" + alpha -> "rgba(r,g,b,a)" for plotly ribbon fills.
explore_rgba <- function(color, alpha) {
  rgb <- grDevices::col2rgb(color)
  sprintf("rgba(%d,%d,%d,%s)", rgb[1], rgb[2], rgb[3], format(alpha))
}

# The slider-to-curve combiner. Runs once in the browser: listens for slider
# moves and restyles the curve traces with the matching precomputed y arrays.
# It never computes a prediction — R (geom_slice) precomputed every curve.
explore_js <- "
function(el, x, data) {
  var pos = data.init.slice();
  function comboIndex() {
    var idx = 0;
    for (var k = 0; k < data.sizes.length; k++) {
      idx = idx * data.sizes[k] + pos[k];
    }
    return idx;
  }
  function apply() {
    var idx = comboIndex();
    var ys = [], traces = [];
    for (var i = 0; i < data.updates.length; i++) {
      var u = data.updates[i];
      ys.push(data.curves[u.curve][u.field][idx]);
      traces.push(u.trace);
    }
    Plotly.restyle(el, {y: ys}, traces);
  }
  el.on('plotly_sliderchange', function(ev) {
    if (!ev || !ev.slider) return;
    var k = data.names.indexOf(ev.slider.name);
    if (k < 0 && typeof ev.slider._index === 'number') k = ev.slider._index;
    if (k < 0 || k >= pos.length) return;
    var step = (ev.step && typeof ev.step._index === 'number') ?
      ev.step._index : ev.slider.active;
    pos[k] = step;
    apply();
  });
}
"

# Render a spec as the interactive plotly widget.
explore_widget <- function(spec) {
  n_sliders <- length(spec$sliders)

  # Fixed pixel geometry so the sliders land predictably below the plot:
  # ~85px per slider in the bottom margin, plot area held at ~310px.
  margin_b <- 70 + 85 * n_sliders
  height <- 440 + 85 * n_sliders
  plot_px <- height - 60 - margin_b

  p <- plotly::plot_ly(height = height)
  n_traces <- 0
  hover <- paste0(spec$x_lab, " = %{x:.4g}<br>", spec$y_lab, " = %{y:.4g}")

  for (pt in spec$points) {
    p <- plotly::add_trace(
      p, x = pt$x, y = pt$y, type = "scatter", mode = "markers",
      name = pt$name, showlegend = spec$legend,
      marker = list(color = pt$colour, size = 8, opacity = 0.85),
      hovertemplate = paste0(hover, "<extra>", pt$name, "</extra>")
    )
    n_traces <- n_traces + 1
  }

  # Curve traces, initialized at the sliders' starting combination. Every
  # trace that must change on a slider move is recorded in `updates` with the
  # spec field ("y", "ymin", "ymax") the JS should read.
  init_idx <- 0
  for (k in seq_along(spec$sliders)) {
    init_idx <- init_idx * spec$sizes[k] + spec$sliders[[k]]$init
  }
  init_idx <- init_idx + 1  # R side is 1-based
  updates <- list()
  for (ci in seq_along(spec$curves)) {
    cv <- spec$curves[[ci]]
    width <- cv$linewidth * 2
    fill <- explore_rgba(cv$colour, cv$alpha)
    if (spec$ribbon != "none") {
      edge <- if (spec$ribbon == "band") {
        list(color = cv$colour, width = width)
      } else {
        list(color = "rgba(0,0,0,0)", width = 0)
      }
      p <- plotly::add_trace(
        p, x = cv$x, y = cv$ymin[[init_idx]], type = "scatter", mode = "lines",
        line = edge, showlegend = FALSE, hoverinfo = "skip"
      )
      updates[[length(updates) + 1]] <-
        list(trace = n_traces, curve = ci - 1, field = "ymin")
      n_traces <- n_traces + 1
      p <- plotly::add_trace(
        p, x = cv$x, y = cv$ymax[[init_idx]], type = "scatter", mode = "lines",
        line = edge, fill = "tonexty", fillcolor = fill,
        showlegend = FALSE, hoverinfo = "skip"
      )
      updates[[length(updates) + 1]] <-
        list(trace = n_traces, curve = ci - 1, field = "ymax")
      n_traces <- n_traces + 1
    }
    if (spec$ribbon != "band") {
      p <- plotly::add_trace(
        p, x = cv$x, y = cv$y[[init_idx]], type = "scatter", mode = "lines",
        line = list(color = cv$colour, width = width),
        name = "slice", showlegend = FALSE,
        hovertemplate = paste0(hover, "<extra>slice</extra>")
      )
      updates[[length(updates) + 1]] <-
        list(trace = n_traces, curve = ci - 1, field = "y")
      n_traces <- n_traces + 1
    }
  }

  # One plotly slider per variable, stacked below the plot. method = "skip"
  # leaves the moves to our JS. Every step keeps its real label — plotly
  # displays the ACTIVE step's label as the "var = value" readout above the
  # rail — but on long grids the rail's own label text is hidden (transparent
  # font; the tick marks stay), or the 37 labels would overlap.
  slider_defs <- lapply(seq_along(spec$sliders), function(k) {
    s <- spec$sliders[[k]]
    n <- length(s$values)
    def <- list(
      active = s$init,
      name = s$var,
      currentvalue = list(prefix = paste0(s$var, " = "), xanchor = "left",
                          font = list(size = 13, color = "#444444")),
      steps = lapply(seq_len(n), function(i) {
        list(method = "skip", label = s$labels[i], value = s$labels[i])
      }),
      x = 0.04, xanchor = "left", len = 0.92,
      y = -(55 + (k - 1) * 85) / plot_px, yanchor = "top",
      pad = list(t = 0, b = 0),
      ticklen = 4, minorticklen = 0
    )
    if (n > 9) def$font <- list(color = "rgba(0,0,0,0)")
    def
  })

  p <- plotly::layout(
    p,
    title = list(text = spec$equation, font = list(size = 14)),
    xaxis = list(title = spec$x_lab, range = as.list(spec$x_range),
                 zeroline = FALSE),
    yaxis = list(title = spec$y_lab, range = as.list(spec$y_range),
                 zeroline = FALSE),
    margin = list(t = 60, b = margin_b),
    sliders = slider_defs
  )
  p <- plotly::config(p, displaylogo = FALSE)

  payload <- list(
    sizes = I(spec$sizes),
    init = I(vapply(spec$sliders, `[[`, integer(1), "init")),
    names = I(vapply(spec$sliders, `[[`, character(1), "var")),
    curves = lapply(spec$curves, function(cv) {
      out <- list(y = lapply(cv$y, I))
      if (!is.null(cv$ymin)) {
        out$ymin <- lapply(cv$ymin, I)
        out$ymax <- lapply(cv$ymax, I)
      }
      out
    }),
    updates = updates
  )
  htmlwidgets::onRender(p, explore_js, data = payload)
}


# ---------------------------------------------------------------------------
# User-facing function
# ---------------------------------------------------------------------------

#' Explore a linear model with sliders
#'
#' `slice_explore()` turns a fitted [lm()] into an interactive plot: the
#' model's data as a scatter with a [geom_slice()] prediction line through it,
#' plus one slider for each predictor the plot does not show. Dragging a
#' slider moves the line to the slice at that value in real time, so you can
#' *feel* how the hidden predictors bend and shift the fit — where the static
#' plot holds them at one imputed value, the sliders let you sweep them.
#'
#' Every curve a slider can show is precomputed by `geom_slice()` itself (the
#' sliders simply choose among slices of the same model), so the lines here
#' and the lines in [autoplot.lm()] / [geom_slice()] always agree — including
#' imputation of unslid predictors, back-transformation of a transformed
#' response, and per-group pinning through `mapping = aes(color = ...)`.
#' Each slider starts at the value `geom_slice()` would impute (mean, or most
#' common level), so the initial view *is* the static autoplot.
#'
#' Numeric sliders feel continuous by default (a fine grid over the observed
#' range). For deliberate, chunky steps give `slider_breaks`; for steps at a
#' numeric variable's observed values wrap it in `factor()`; factor and
#' character predictors step through their levels automatically.
#'
#' The result is a regular plotly htmlwidget: it displays in the RStudio
#' Viewer, and renders fully interactive (no R session needed) in R Markdown /
#' Quarto HTML output.
#'
#' @param model A linear model fitted by [lm()] **with a `data` argument**.
#' @param sliders Which predictors get sliders. `TRUE` (default) gives one to
#'   every predictor the plot does not otherwise show. Or name them: a bare
#'   name (`sliders = cyl`), several (`sliders = c(disp, cyl)`), strings
#'   (`sliders = "cyl"`), or `factor(cyl)` to step a numeric predictor through
#'   its observed values instead of a continuous range.
#' @param slider_breaks Exact values for a slider's steps — intentionally
#'   jumpy, where the default grid feels continuous. A named list such as
#'   `slider_breaks = list(cyl = c(4, 6, 8))`, or a bare vector when there is
#'   only one slider.
#' @param slider_steps How many steps a continuous slider's automatic grid
#'   gets: a single number for all sliders or a named list, e.g.
#'   `slider_steps = list(hp = 15)`. The default aims for smooth dragging
#'   while keeping the precomputed curves light.
#' @param ... Passed on to [geom_slice()] — for example
#'   `predict_vars = list(hp = 110)` to hold an unslid predictor at a chosen
#'   value, or `interval = "confidence"` for a ribbon that moves with the
#'   line.
#' @param mapping Extra aesthetics created with [ggplot2::aes()], as in
#'   [autoplot.lm()] — e.g. `mapping = aes(color = factor(cyl))` pins `cyl`
#'   per color group (and its slider is dropped, since the plot now shows it).
#'   Only the color aesthetic is displayed.
#' @param data A data frame to draw the scatter from instead of the data
#'   recovered from the model, as in [autoplot.lm()].
#' @param x_axis The name of the predictor to place on the x-axis. Defaults to
#'   the model's first numeric predictor.
#'
#' @returns A plotly htmlwidget: the scatter, the slice line(s), and one
#'   slider per explored predictor.
#'
#' @seealso [autoplot.lm()] — `autoplot(model, sliders = TRUE)` is a shortcut
#'   for this function; [geom_slice()], which computes every curve shown;
#'   [scatter_3d()] for the 3-D surface view of a two-predictor model.
#'
#' @examples
#' if (interactive()) {
#'   model <- lm(mpg ~ disp + hp + wt, data = mtcars)
#'
#'   # Sliders for hp and wt (disp is on the x-axis)
#'   slice_explore(model)
#'
#'   # ... the same, via autoplot
#'   autoplot(model, sliders = TRUE)
#'
#'   # Only slide hp; hold wt at a chosen value
#'   slice_explore(model, sliders = hp, predict_vars = list(wt = 3))
#'
#'   # Deliberate steps instead of a continuous feel
#'   slice_explore(model, sliders = hp, slider_breaks = c(66, 110, 245))
#'
#'   # A numeric predictor stepped through its observed values
#'   model2 <- lm(mpg ~ disp + hp + cyl, data = mtcars)
#'   slice_explore(model2, sliders = c(hp, factor(cyl)))
#'
#'   # Pin cyl per color group, slide the rest, with a confidence ribbon
#'   slice_explore(model2, mapping = aes(color = factor(cyl)),
#'                 interval = "confidence")
#' }
#'
#' @export
slice_explore <- function(model, sliders = TRUE, slider_breaks = NULL,
                          slider_steps = NULL, ..., mapping = NULL,
                          data = NULL, x_axis = NULL) {
  sliders_quo <- rlang::enquo(sliders)
  spec <- explore_spec(model, sliders_quo, slider_breaks = slider_breaks,
                       slider_steps = slider_steps, mapping = mapping,
                       data = data, x_axis = x_axis, ...)
  explore_widget(spec)
}
