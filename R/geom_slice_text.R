# geom_slice_text() — end-of-line text labels for geom_slice() lines.
#
# Architecture (mirrors geom_slice.R; design record in
# for_devs/geom_slice_text_handoff.md):
#
#   geom_slice_text()  validates user input and returns a `slice_text_spec`.
#                      It takes NO model or predict_vars — those are borrowed
#                      from the plot's existing geom_slice() layers at add time.
#   ggplot_add.slice_text_spec
#                      scans plot$layers for slice layers, warns when there are
#                      none or when they use different models, then adds one
#                      text layer per slice layer (plus the corner key and the
#                      scale expansions, which only the whole plot can carry).
#   StatSliceText      re-resolves the same slice spec as StatSlice and reduces
#                      each line to its endpoint, attaching the label text.
#   GeomSliceText      GeomText that displaces its labels by `offset` POINTS at
#                      draw time, so the gap is constant regardless of label
#                      text, axis range, or plot size.


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Format one held value for a label: bare numbers, bare strings (no quotes).
label_value <- function(value) {
  if (is.numeric(value)) format(signif(value, 4)) else as.character(value)
}

# Join per-variable label parts in the requested style.
# style "variable" -> "x2: 0; x3: 1"; "value"/"legend" -> "0; 1".
label_text <- function(vars, values, style) {
  parts <- vapply(seq_along(vars), function(i) {
    val <- label_value(values[[i]])
    if (style == "variable") paste0(vars[i], ": ", val) else val
  }, character(1))
  paste(parts, collapse = "; ")
}

# TRUE for layers created by geom_slice() (and not by geom_slice_text() itself,
# whose layers also carry a model in their stat params).
is_slice_layer <- function(layer) {
  inherits(layer$stat, "StatSlice") && !inherits(layer$stat, "StatSliceText") &&
    !is.null(layer$stat_params$model)
}

# The grouping-aesthetic variables the plot pins per group: aesthetics (other
# than x/y/group) whose expression is exactly one of the model's predictors.
# Mirrors the group_aes scan in build_slice_spec(), but runs at add time on the
# plot's own mapping (labels must be sizeable before the plot is built).
slice_text_group_vars <- function(mapping, model) {
  response_vars <- all.vars(formula(model)[[2]])
  predictor_vars <- setdiff(all.vars(delete.response(terms(model))), response_vars)
  vars <- character(0)
  for (aes_name in setdiff(names(mapping), c("x", "y", "group"))) {
    v <- all.vars(rlang::quo_get_expr(mapping[[aes_name]]))
    if (length(v) == 1 && v %in% predictor_vars) vars <- c(vars, v)
  }
  unique(vars)
}

# The predict_vars one slice layer's labels describe: the layer's own, plus the
# band's variable held at the two values that make its edges — replacing any
# individual values predict_vars gave it.
#
# This is what makes band labels work. The text layer never receives `band`
# itself, so those two values make it draw the two edge lines, one label each,
# named by the value that produced it — right way up even when the effect is
# decreasing. Add-time and therefore provisional; see slice_layer_band().
slice_text_predict_vars <- function(slice_layer, plot) {
  pv <- slice_layer$stat_params$predict_vars %||% list()
  band <- slice_layer_band(slice_layer, plot)
  if (!is.null(band)) pv[[band$var]] <- band$values
  pv
}

# Every label string one slice layer will produce, computed at add time (used
# to size the x-expansion and the corner key). predict_vars labels win over
# grouping-aesthetic labels, mirroring StatSliceText.
slice_text_labels <- function(slice_layer, plot, style) {
  pv <- slice_text_predict_vars(slice_layer, plot)
  if (length(pv) > 0) {
    combos <- expand.grid(pv, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    return(vapply(seq_len(nrow(combos)), function(i) {
      label_text(names(pv), lapply(names(pv), function(v) combos[[v]][i]), style)
    }, character(1)))
  }
  model <- slice_layer$stat_params$model
  vars <- slice_text_group_vars(plot$mapping, model)
  if (length(vars) == 0 || !is.data.frame(plot$data)) return(character(0))
  values <- lapply(vars, function(v) {
    if (is.null(plot$data[[v]])) return(character(0))
    sort(unique(as.character(plot$data[[v]])))
  })
  combos <- expand.grid(values, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  if (nrow(combos) == 0) return(character(0))
  vapply(seq_len(nrow(combos)), function(i) {
    label_text(vars, lapply(seq_along(vars), function(j) combos[[j]][i]), style)
  }, character(1))
}

# Width of the widest label in POINTS, in the font the layer draws with
# (`size` is the GeomSliceText default, in mm). nchar() is a poor stand-in:
# "iiiiiiii" and "MMMMMMMM" are both 8 characters and differ threefold.
label_width_pt <- function(labels, size = 3.88, family = "") {
  if (length(labels) == 0) return(0)
  # Font metrics need a device, but measuring on the current one would open a
  # page on it — a blank leading page in a png()/pdf() script, or the user's
  # graphics window popping up as a side effect of `+`.
  old <- grDevices::dev.cur()
  grDevices::pdf(NULL)
  on.exit({
    grDevices::dev.off()
    if (old != 1L) grDevices::dev.set(old)
  }, add = TRUE)
  gp <- grid::gpar(fontsize = size * .pt, fontfamily = family)
  max(vapply(labels, function(l) {
    grid::convertWidth(grid::grobWidth(grid::textGrob(l, gp = gp)), "pt",
                       valueOnly = TRUE)
  }, numeric(1)))
}

# Panels side by side, each of which gets its own share of the plot's width.
# Like everything else here, blind to a facet added after geom_slice_text().
facet_col_count <- function(plot) {
  tryCatch({
    facet <- plot$facet
    params <- facet$params
    quo_vars <- function(qs) {
      unique(unlist(lapply(qs, function(q) all.vars(rlang::quo_get_expr(q)))))
    }
    n_combos <- function(vars) {
      vars <- intersect(vars, names(plot$data))
      if (length(vars) == 0) return(1L)
      nrow(unique(plot$data[vars]))
    }
    if (inherits(facet, "FacetGrid")) {
      return(max(1L, n_combos(quo_vars(params$cols))))
    }
    if (inherits(facet, "FacetWrap")) {
      n <- n_combos(quo_vars(params$facets))
      if (!is.null(params$ncol)) return(max(1L, params$ncol))
      if (!is.null(params$nrow)) return(max(1L, ceiling(n / params$nrow)))
      # ggplot2's own default layout when neither nrow nor ncol is given.
      return(max(1L, grDevices::n2mfrow(n)[1]))
    }
    1L
  }, error = function(e) 1L)
}

# A pessimistic guess at the drawn width of one panel, in POINTS, from the
# device open at add time (the drawing device in every workflow that opens one
# first: the RStudio pane, a png()/pdf() script, a knitr chunk; 7x7 in when
# there is none). The allowance covers the axis, its title, the plot margins
# and a right-hand legend, and errs high — over-reserving only costs white
# space, under-reserving clips.
panel_width_pt <- function(plot) {
  device_pt <- grDevices::dev.size("in")[1] * 72
  max((device_pt - 140) / facet_col_count(plot), 100)
}

# The variable names the labels describe (for the "labels: x2; x3" corner key).
slice_text_label_vars <- function(slice_layer, plot) {
  pv <- slice_text_predict_vars(slice_layer, plot)
  if (length(pv) > 0) return(names(pv))
  slice_text_group_vars(plot$mapping, slice_layer$stat_params$model)
}


# ---------------------------------------------------------------------------
# ggproto classes
# ---------------------------------------------------------------------------

#' StatSliceText
#'
#' The stat behind [geom_slice_text()]. It resolves the same slice spec as
#' [StatSlice] (borrowed from the plot's `geom_slice()` layer), reduces each
#' prediction line to its endpoint, and attaches the label text.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{Stat}.
#'
#' @export
StatSliceText <- ggproto(
  "StatSliceText",
  Stat,
  required_aes = c("x", "y"),
  extra_params = c("na.rm", "mapping", "model_name"),

  # Same spec resolution as StatSlice, but silenced: geom_slice() already
  # announced any imputed values / back-transformations for these slices, and
  # the user must not see each message twice.
  compute_layer = function(self, data, params, layout) {
    params$slice_spec <- suppressMessages(
      resolve_group_pins(build_slice_spec(params, layout), data)
    )
    ggproto_parent(Stat, self)$compute_layer(data, params, layout)
  },

  compute_group = function(data, scales, model, predict_vars = list(),
                           back_transform = NULL, mapping = NULL,
                           slice_spec = NULL, label_style = "variable",
                           location = "right", na.rm = FALSE) {
    # The endpoints don't depend on n, so a short line is enough.
    lines <- suppressMessages(
      compute_slice_group(data, scales, slice_spec, n = 5, interval = "none")
    )
    if (is.null(lines) || nrow(lines) == 0) return(lines)

    pick_end <- function(d) {
      d[if (location == "left") which.min(d$x) else which.max(d$x), , drop = FALSE]
    }
    ends <- do.call(rbind, lapply(split(lines, lines$group), pick_end))

    # Recover which held-value combination each line came from, using the same
    # expand.grid ordering and group-id scheme as compute_slice_group().
    combos <- expand.grid(slice_spec$held, KEEP.OUT.ATTRS = FALSE,
                          stringsAsFactors = FALSE)
    combo_of <- if (nrow(combos) > 1) {
      ends$group - data$group[1] * nrow(combos) + 1
    } else {
      rep(1L, nrow(ends))
    }

    label_vars <- intersect(names(predict_vars), names(combos))
    if (length(label_vars) > 0) {
      # Label the values the user chose to vary, in predict_vars order.
      ends$label <- vapply(combo_of, function(i) {
        label_text(label_vars,
                   lapply(label_vars, function(v) combos[[v]][i]),
                   label_style)
      }, character(1))
    } else if (length(slice_spec$group_aes) > 0) {
      # No predict_vars: label the grouping-aesthetic value pinning this group.
      vars <- unlist(slice_spec$group_aes, use.names = FALSE)
      values <- lapply(names(slice_spec$group_aes),
                       function(aes_name) data[[aes_name]][1])
      ends$label <- label_text(vars, values, label_style)
    } else {
      ends$label <- ""
    }
    ends
  }
)

#' GeomSliceText
#'
#' The geom behind [geom_slice_text()]: [ggplot2::GeomText] whose labels are
#' displaced by a fixed number of points at draw time (like axis tick label
#' margins), so the gap between line end and label is constant regardless of
#' label text, axis range, or plot size.
#'
#' @format An object of class \code{ggproto}, inheriting from \code{GeomText}.
#'
#' @export
GeomSliceText <- ggproto(
  "GeomSliceText",
  GeomText,
  default_aes = aes(
    colour = "skyblue",
    size = 3.88,
    angle = 0,
    hjust = 0.5,
    vjust = 0.5,
    alpha = NA,
    family = "",
    fontface = 1,
    lineheight = 1.2
  ),
  # No `...`: with dots in draw_panel, Geom$parameters() falls back to
  # draw_group's formals and `offset_points` would not be a layer parameter.
  draw_panel = function(self, data, panel_params, coord, parse = FALSE,
                        na.rm = FALSE, check_overlap = FALSE,
                        size.unit = "mm", offset_points = 0) {
    grob <- ggproto_parent(GeomText, self)$draw_panel(
      data, panel_params, coord, parse = parse, na.rm = na.rm,
      check_overlap = check_overlap, size.unit = size.unit
    )
    if (!identical(offset_points, 0)) {
      grob$x <- grob$x + grid::unit(offset_points, "pt")
    }
    grob
  }
)


# ---------------------------------------------------------------------------
# Add-time assembly
# ---------------------------------------------------------------------------

# Adding to a plot is the only moment geom_slice_text() can see the
# geom_slice() layers it borrows everything from — and the only place scale
# expansions can be added (a layer alone can never alter scales).
#' @export
#' @noRd
ggplot_add.slice_text_spec <- function(object, plot, ...) {
  slice_layers <- Filter(is_slice_layer, plot$layers)

  if (length(slice_layers) == 0) {
    slice_warn(
      what = "geom_slice_text() found no geom_slice() layer to label, so no labels were drawn.",
      hint = "Add the slice first, such as 'geom_slice(model) + geom_slice_text()'."
    )
    return(plot)
  }

  models <- lapply(slice_layers, function(l) l$stat_params$model)
  if (!all(vapply(models[-1], identical, logical(1), y = models[[1]]))) {
    names <- unique(vapply(slice_layers,
                           function(l) l$stat_params$model_name %||% "model",
                           character(1)))
    slice_warn(
      what = paste0("geom_slice_text() found geom_slice() layers with different models (",
                    paste0("`", names, "`", collapse = ", "),
                    "), so no labels were drawn."),
      hint = "Use the same model in every geom_slice() layer, or remove the layers whose model differs."
    )
    return(plot)
  }

  # Manual hjust disables the automatic point-offset entirely.
  right <- object$location == "right"
  hjust <- object$hjust %||% (if (right) 0 else 1)
  offset_points <- if (is.null(object$hjust)) {
    if (right) object$offset else -object$offset
  } else {
    0
  }

  # One text layer per slice layer: each inherits its own layer's model,
  # predict_vars, and fixed color, so several layers of the same model are
  # labeled as if their predict_vars were combined.
  for (sl in slice_layers) {
    params <- list(
      model = sl$stat_params$model,
      model_name = sl$stat_params$model_name,
      predict_vars = slice_text_predict_vars(sl, plot),
      back_transform = sl$stat_params$back_transform,
      label_style = object$style,
      location = object$location,
      offset_points = offset_points,
      hjust = hjust,
      vjust = object$vjust %||% 0.5
    )
    colour <- object$color %||% sl$aes_params$colour
    if (!is.null(colour)) params$colour <- colour
    plot <- plot + layer(
      stat = StatSliceText,
      geom = GeomSliceText,
      position = "identity",
      inherit.aes = TRUE,
      show.legend = FALSE,
      params = params,
      layer_class = SliceLayer
    )
  }

  # style = "legend": bare values at the line ends need a key naming the
  # variables. Key color = the line color when all lines share one, neutral
  # gray when they differ (e.g. a mapped color aesthetic).
  if (object$style == "legend") {
    key_vars <- slice_text_label_vars(slice_layers[[1]], plot)
    if (length(key_vars) > 0) {
      fixed <- vapply(slice_layers,
                      function(l) l$aes_params$colour %||% "skyblue",
                      character(1))
      mapped <- length(slice_text_group_vars(plot$mapping, models[[1]])) > 0
      key_color <- object$color %||%
        (if (!mapped && length(unique(fixed)) == 1) fixed[1] else "gray30")
      plot <- plot + annotate(
        "text", x = Inf, y = Inf,
        label = paste0("labels: ", paste(key_vars, collapse = "; ")),
        hjust = 1.1, vjust = 1.5, color = key_color
      )
    }
  }

  # The geom manages its own margin: widen the x-range on the label side,
  # enough for the widest label; style = "legend" also adds y-headroom so the
  # corner key clears the topmost line's label.
  if (isTRUE(object$expand)) {
    labels <- unique(unlist(lapply(slice_layers, slice_text_labels,
                                   plot = plot, style = object$style)))
    if (length(labels) > 0) {
      # The labels need a fixed number of points: the widest one, the
      # draw-time offset (which never trains the x-scale), and a gap.
      needed <- label_width_pt(labels) + abs(offset_points) + 4
      # `frac` is the share of the panel they claim, `ex` the same space as a
      # multiple of the data range, which is what expansion() takes:
      # panel = range * (1 + 0.05 + ex). The cap keeps a huge label on a tiny
      # device from erasing the data.
      frac <- min(needed / panel_width_pt(plot), 0.4)
      ex <- frac * 1.05 / (1 - frac)
      mult <- if (right) c(0.05, ex) else c(ex, 0.05)
      plot <- plot + scale_x_continuous(expand = expansion(mult = mult))
      if (object$style == "legend") {
        plot <- plot + scale_y_continuous(expand = expansion(mult = c(0.05, 0.1)))
      }
    }
  }

  plot
}


# ---------------------------------------------------------------------------
# User-facing constructor
# ---------------------------------------------------------------------------

#' Label the lines drawn by geom_slice()
#'
#' `geom_slice_text()` writes a text label at the end of each line drawn by
#' the plot's [geom_slice()] layers. Multi-value `predict_vars` draw visually
#' identical lines with nothing distinguishing them; labels fix that, and
#' double as a legend replacement for grouping aesthetics.
#'
#' It takes no `model` or `predict_vars` — everything is borrowed from the
#' plot's existing `geom_slice()` layers, so add it *after* them. Labels
#' describe the `predict_vars` values (`"x2: 0"`, joined with `"; "` when
#' several variables are crossed); when the slice layer has no `predict_vars`,
#' labels describe the grouping aesthetic instead (`"g: A"`). Each label
#' inherits its line's color.
#'
#' @param style How to write the labels: `"variable"` (default) writes
#'   `"x2: 0"`; `"value"` writes the bare `"0"`; `"legend"` writes bare values
#'   plus a key in the panel's top-right corner naming the variables
#'   (`"labels: x2; x3"`).
#' @param location Which end of the line to label: `"right"` (default) or
#'   `"left"`.
#' @param offset Gap between the line end and the label edge, in points
#'   (default 5). The gap is constant regardless of label text, axis range,
#'   or plot size.
#' @param hjust,vjust Manual text justification. Default `NULL` anchors the
#'   label at the line end, displaced by `offset`; setting `hjust` yourself
#'   disables the automatic offset entirely.
#' @param color Label color. Default `NULL` inherits each line's color.
#' @param expand If `TRUE` (default), widen the x-range on the label side so
#'   the labels fit (plus y-headroom for the `"legend"` key). `FALSE` leaves
#'   the scales alone. The room reserved is measured from the widest label's
#'   drawn width and the size of the graphics device open when the layer is
#'   added, so it errs on the generous side; a plot re-sized much narrower
#'   afterwards may still clip.
#'
#' @returns An object that adds the label layers when added to a ggplot.
#'
#' @seealso [geom_slice()] for the layers being labeled;
#'   [geom_slice_subtitle()] / [geom_slice_caption()] to describe the slice
#'   in the plot's text instead.
#'
#' @examples
#' library(ggplot2)
#'
#' # Two visually identical lines, told apart by their labels
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, predict_vars = list(hp = c(66, 335))) +
#'   geom_slice_text()
#'
#' # A projection band, labeled on each edge
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model, band = TRUE) +
#'   geom_slice_text()
#'
#' @export
geom_slice_text <- function(style = "variable",
                            location = "right",
                            offset = 5,
                            hjust = NULL,
                            vjust = NULL,
                            color = NULL,
                            expand = TRUE) {
  styles <- c("variable", "value", "legend")
  if (!is.character(style) || length(style) != 1 || !style %in% styles) {
    slice_abort(
      what = paste0("`style` must be one of ",
                    paste0('"', styles, '"', collapse = ", "), "."),
      hint = "For example, 'style = \"value\"'."
    )
  }
  locations <- c("right", "left")
  if (!is.character(location) || length(location) != 1 || !location %in% locations) {
    slice_abort(
      what = '`location` must be "right" or "left".',
      hint = "For example, 'location = \"left\"'."
    )
  }
  if (!is.numeric(offset) || length(offset) != 1 || is.na(offset)) {
    slice_abort(
      what = "`offset` must be a single number of points.",
      hint = "For example, 'offset = 5'."
    )
  }
  if (!is.logical(expand) || length(expand) != 1 || is.na(expand)) {
    slice_abort(
      what = "`expand` must be TRUE or FALSE.",
      hint = "For example, 'expand = FALSE'."
    )
  }
  structure(
    list(style = style, location = location, offset = offset,
         hjust = hjust, vjust = vjust, color = color, expand = expand),
    class = "slice_text_spec"
  )
}
