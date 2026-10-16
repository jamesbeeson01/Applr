# THROWAWAY (ticket 03). A trimmed copy of the P5 slider prototype
# (scratch/sliders/_core.R, _html.R, p5_svg_js.R), which is gitignored and so
# invisible to CI. Only the payload build is kept; no HTML is written.

quiet <- function(expr) suppressMessages(expr)

autoplot_recipe <- function(model, ...) {
  function(predict_vars = list()) {
    autoplot(model, predict_vars = predict_vars, summary = FALSE, ...)
  }
}

slice_layers_of <- function(plot) Filter(is_slice_layer, plot$layers)

slider_grid <- function(column, default, n) {
  if (!is.numeric(column)) {
    return(if (is.factor(column)) levels(column) else sort(unique(as.character(column))))
  }
  u <- sort(unique(column[!is.na(column)]))
  stops <- if (length(u) <= n) u else seq(min(u), max(u), length.out = n)
  sort(unique(c(stops, default)))
}

slider_plan <- function(recipe, n = 9) {
  p0 <- quiet(recipe(list()))
  model <- slice_layers_of(p0)[[1]]$stat_params$model
  held <- slice_subtitle_held(p0, slice_layers_of(p0), model)$held
  raw_data <- slice_model_frame(model)
  vars <- names(held)
  grids <- lapply(setNames(vars, vars), function(v) slider_grid(raw_data[[v]], held[[v]], n))
  plan <- list(recipe = recipe, model = model, vars = vars, grids = grids,
               start = held[vars], combos = expand.grid(grids, KEEP.OUT.ATTRS = FALSE,
                                                        stringsAsFactors = FALSE))
  plan$y_limits <- slider_y_limits(quiet(ggplot_build(recipe(plan$start))))
  plan$all_build <- quiet(ggplot_build(plot_at(plan, grids)))
  plan
}

slider_y_limits <- function(built) {
  ys <- unlist(lapply(built$data, function(d) d[intersect(c("y", "ymin", "ymax"), names(d))]))
  y_trans <- scale_transformation(built$layout$panel_scales_y[[1]], "y")
  y_trans$inverse(range(ys[is.finite(ys)]))
}

plot_at <- function(plan, values) {
  quiet(plan$recipe(values)) + coord_cartesian(ylim = plan$y_limits)
}

combo_index <- function(plan, values) {
  hit <- Reduce(`&`, lapply(plan$vars, function(v) plan$combos[[v]] == values[[v]]))
  which(hit)
}

stat_held_grid <- function(plot, layer, model) {
  pv <- layer$stat_params$predict_vars %||% list()
  ctx <- slice_add_time_context(plot, model, pv)
  band <- slice_layer_band(layer, plot, ctx)
  vars <- setdiff(ctx$predictor_vars,
                  c(ctx$x_vars, ctx$group_vars, ctx$facet_vars, band$var))
  vals <- lapply(setNames(vars, vars), function(v) {
    if (!is.null(pv[[v]])) pv[[v]] else quiet(impute_value(ctx$raw_data[[v]], v))
  })
  expand.grid(vals, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
}

slider_curves <- function(plan) {
  b <- plan$all_build
  plot <- quiet(plan$recipe(plan$grids))
  out <- list()
  for (li in which(vapply(plot$layers, is_slice_layer, logical(1)))) {
    layer <- plot$layers[[li]]
    grid <- stat_held_grid(plot, layer, plan$model)
    n <- nrow(grid)
    d <- b$data[[li]]
    i <- d$group %% n + 1
    d$combo <- if (length(plan$vars)) {
      match(do.call(paste, grid[i, plan$vars, drop = FALSE]), do.call(paste, plan$combos))
    } else 1L
    others <- setdiff(names(grid), plan$vars)
    d$line <- paste(li, d$PANEL, d$group %/% n,
                    if (length(others)) do.call(paste, grid[i, others, drop = FALSE]))
    d$layer <- li
    d$kind <- if (inherits(layer$geom, "GeomSliceBand")) "band" else "line"
    out[[length(out) + 1]] <- d
  }
  do.call(rbind, out)
}

slider_text <- function(plan, curves) {
  b <- plan$all_build
  plot <- quiet(plan$recipe(plan$grids))
  text_layers <- which(vapply(plot$layers, function(l) inherits(l$stat, "StatSliceText"), logical(1)))
  if (length(text_layers) == 0) return(NULL)
  ends <- do.call(rbind, lapply(split(curves, list(curves$line, curves$combo), drop = TRUE), function(d) {
    e <- d[c(which.min(d$x), which.max(d$x)), ]
    edges <- intersect(c("y", "ymin", "ymax"), names(e))
    do.call(rbind, lapply(edges, function(edge) data.frame(
      PANEL = e$PANEL, x = e$x, y = e[[edge]], edge = edge, line = e$line, combo = e$combo)))
  }))
  key <- function(d) paste(d$PANEL, signif(d$x, 10), signif(d$y, 10))
  out <- lapply(text_layers, function(li) {
    d <- b$data[[li]]
    hit <- match(key(d), key(ends))
    d$combo <- ends$combo[hit]
    d$offset_points <- plot$layers[[li]]$geom_params$offset_points %||% 0
    d[!is.na(hit), ]
  })
  do.call(rbind, out)
}

slider_subtitles <- function(plan) {
  p <- quiet(plan$recipe(plan$start))
  s0 <- p$labels$subtitle %||% ""
  held <- slice_subtitle_held(p, slice_layers_of(p), plan$model)$held
  old <- if (length(held)) slice_subtitle_held_line(held) else NA
  n <- nrow(plan$combos)
  if (!is.na(old) && grepl(old, s0, fixed = TRUE) && all(plan$vars %in% names(held))) {
    return(vapply(seq_len(n), function(i) {
      h <- modifyList(held, as.list(plan$combos[i, , drop = FALSE]))
      sub(old, slice_subtitle_held_line(h), s0, fixed = TRUE)
    }, character(1)))
  }
  vapply(seq_len(n), function(i) {
    quiet(plan$recipe(as.list(plan$combos[i, , drop = FALSE])))$labels$subtitle %||% ""
  }, character(1))
}

slider_meta <- function(plan) {
  n <- unname(lengths(plan$grids))
  list(
    vars = as.list(plan$vars),
    grids = unname(lapply(plan$grids, as.list)),
    numeric = I(unname(vapply(plan$grids, is.numeric, logical(1)))),
    start = I(unname(vapply(plan$vars, function(v) match(plan$start[[v]], plan$grids[[v]]) - 1L, integer(1)))),
    stride = as.list(cumprod(c(1L, n))[seq_along(n)])
  )
}

background_plot <- function(plan) {
  bg <- plot_at(plan, plan$start)
  bg$layers <- lapply(bg$layers, function(l) {
    if (!inherits(l$stat, "StatSlice") || inherits(l$stat, "StatSliceText")) return(l)
    silent <- ggproto(NULL, l$geom, draw_panel = function(...) grid::nullGrob())
    keyed <- ggproto(NULL, l)
    keyed$geom <- silent
    keyed
  })
  bg$layers <- Filter(function(l) !inherits(l$stat, "StatSliceText"), bg$layers)
  bg
}

# Panel boxes in svglite's own units, as P5 measures them. svglite uses system
# font metrics, so these are the part most likely to differ by platform.
svglite_boxes <- function(bg, width, height) {
  f <- tempfile(fileext = ".svg")
  on.exit(unlink(f))
  built <- quiet(ggplot_build(bg))
  svglite::svglite(f, width = width, height = height)
  print(bg)
  grid::grid.force()
  vps <- grid::grid.ls(viewports = TRUE, grobs = FALSE, print = FALSE)$name
  boxes <- do.call(rbind, lapply(unique(grep("^panel", vps, value = TRUE)), function(vp) {
    grid::seekViewport(vp)
    lo <- grid::deviceLoc(grid::unit(0, "npc"), grid::unit(0, "npc"), valueOnly = TRUE)
    hi <- grid::deviceLoc(grid::unit(1, "npc"), grid::unit(1, "npc"), valueOnly = TRUE)
    data.frame(x0 = lo$x * 72, x1 = hi$x * 72,
               y0 = (height - lo$y) * 72, y1 = (height - hi$y) * 72)
  }))
  grDevices::dev.off()
  boxes$COL <- match(round(boxes$x0), sort(unique(round(boxes$x0))))
  boxes$ROW <- match(round(boxes$y1), sort(unique(round(boxes$y1))))
  boxes <- merge(boxes, built$layout$layout[c("PANEL", "ROW", "COL")], by = c("ROW", "COL"))
  pp <- built$layout$panel_params
  boxes$xr <- lapply(as.integer(boxes$PANEL), function(i) pp[[i]]$x.range)
  boxes$yr <- lapply(as.integer(boxes$PANEL), function(i) pp[[i]]$y.range)
  boxes
}

to_svg <- function(box, x = NULL, y = NULL) {
  if (!is.null(x)) return(box$x0 + (x - box$xr[[1]][1]) / diff(box$xr[[1]]) * (box$x1 - box$x0))
  box$y0 + (y - box$yr[[1]][1]) / diff(box$yr[[1]]) * (box$y1 - box$y0)
}

# Everything the P5 page is built from: the payload exactly as P5 embeds it,
# the same curves in data units (to tell svglite drift from model drift), the
# background plot, and the slider config.
p5_build <- function(recipe, n = 9, width = 7, height = 5) {
  plan <- slider_plan(recipe, n = n)
  curves <- slider_curves(plan)
  text <- slider_text(plan, curves)
  subtitles <- slider_subtitles(plan)
  bg_plot <- background_plot(plan)
  boxes <- svglite_boxes(bg_plot, width, height)
  box_of <- function(panel) boxes[boxes$PANEL == panel, ]
  r2 <- function(v) round(v, 2)

  data_lines <- list()
  lines <- lapply(unique(curves$line), function(ln) {
    d <- curves[curves$line == ln, ]
    d <- d[order(d$combo, d$x), ]
    box <- box_of(d$PANEL[1])
    by_combo <- split(d, d$combo)
    cols <- Filter(function(col) !is.null(d[[col]]) && !all(is.na(d[[col]])), c("y", "ymin", "ymax"))
    data_lines[[ln]] <<- list(x = by_combo[[1]]$x,
                              ys = lapply(setNames(cols, cols), function(col) unname(lapply(by_combo, `[[`, col))))
    ys <- function(col) if (col %in% cols) lapply(by_combo, function(g) r2(to_svg(box, y = g[[col]])))
    fill <- if (d$fill[1] == GeomSlice$default_aes$fill) d$colour[1] else d$fill[1]
    list(panel = as.integer(d$PANEL[1]), kind = d$kind[1],
         colour = d$colour[1], fill = fill, alpha = d$alpha[1],
         lw = r2(d$linewidth[1] * .pt * 72 / 96), lty = d$linetype[1],
         x = r2(to_svg(box, x = by_combo[[1]]$x)),
         y = unname(ys("y")), ymin = unname(ys("ymin")), ymax = unname(ys("ymax")))
  })
  labels <- if (!is.null(text)) lapply(split(text, text$combo), function(t) {
    box <- boxes[match(t$PANEL, boxes$PANEL), ]
    list(x = r2(vapply(seq_len(nrow(t)), function(i) to_svg(box[i, ], x = t$x[i]), 0) + t$offset_points),
         y = r2(vapply(seq_len(nrow(t)), function(i) to_svg(box[i, ], y = t$y[i]), 0)),
         label = t$label, colour = t$colour, size = r2(t$size * .pt), panel = as.integer(t$PANEL))
  })
  payload <- list(meta = slider_meta(plan), lines = lines, labels = unname(labels),
                  subtitles = subtitles,
                  clips = lapply(seq_len(nrow(boxes)), function(i) as.list(boxes[i, c("PANEL", "x0", "x1", "y0", "y1")])))
  list(
    payload = payload,
    data_payload = list(lines = unname(data_lines), subtitles = subtitles),
    background = bg_plot,
    shell = list(meta = slider_meta(plan), width = width, height = height,
                 svglite = as.character(utils::packageVersion("svglite")))
  )
}

model_a <- lm(mpg ~ disp * hp + poly(wt, 2) + cyl, data = mtcars)
recipe_a <- autoplot_recipe(model_a)

model_b <- lm(mpg ~ disp + hp + wt + am, data = mtcars)
recipe_b <- function(predict_vars = list()) {
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model_b, predict_vars = c(list(am = c(0, 1)), predict_vars), band = "wt") +
    geom_slice_text() +
    geom_slice_subtitle()
}
