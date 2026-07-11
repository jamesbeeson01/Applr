# geom_slice_subtitle() — a plot subtitle describing the geom_slice() layers.
#
# Architecture (mirrors geom_slice_text.R):
#
#   geom_slice_subtitle()  validates user input and returns a
#                          `slice_subtitle_spec`. It takes NO model or
#                          predict_vars — those are borrowed from the plot's
#                          existing geom_slice() layers at add time.
#   ggplot_add.slice_subtitle_spec
#                          scans plot$layers for slice layers, warns when there
#                          are none or when they use different models, works out
#                          which held values are NOT already labeled elsewhere
#                          on the plot (geom_slice_text labels, the legend,
#                          facet strips), and sets the plot subtitle.
#
# The subtitle is add-time text, not a layer: everything it reports (imputed
# means, predict_vars, what the legend covers) is knowable from the plot object
# before it is built, mirroring the held-variable logic of build_slice_spec().


# TRUE for layers created by geom_slice_text() (which carry the same slice
# stat params as the slice layer they label).
is_slice_text_layer <- function(layer) {
  inherits(layer$stat, "StatSliceText")
}

# The held (unlabeled) values one plot's slice layers imply, as a named list in
# the model's predictor order. Reproduces the held-variable logic of
# build_slice_spec() at add time: predictors on the x-axis, pinned by a
# grouping aesthetic (the legend labels those), pinned by a facet variable
# (the strips label those), or already labeled by geom_slice_text() are
# excluded; what's left is a predict_vars value or the imputed default.
slice_subtitle_held <- function(plot, slice_layers, model) {
  raw_data <- slice_model_frame(model)
  response_vars <- all.vars(formula(model)[[2]])
  predictor_vars <- setdiff(all.vars(delete.response(terms(model))), response_vars)

  # predict_vars combined across the slice layers (they share one model)
  predict_vars <- list()
  for (sl in slice_layers) {
    pv <- sl$stat_params$predict_vars %||% list()
    for (v in names(pv)) {
      predict_vars[[v]] <- unique(c(predict_vars[[v]], pv[[v]]))
    }
  }

  x_vars <- if (!is.null(plot$mapping$x)) {
    intersect(all.vars(rlang::quo_get_expr(plot$mapping$x)), predictor_vars)
  } else {
    character(0)
  }

  # explicit predict_vars win over group pinning, as in build_slice_spec()
  group_vars <- setdiff(slice_text_group_vars(plot$mapping, model),
                        names(predict_vars))

  facet_params <- plot$facet$params
  facet_vars <- intersect(
    unique(c(names(facet_params$facets %||% list()),
             names(facet_params$rows %||% list()),
             names(facet_params$cols %||% list()))),
    predictor_vars
  )
  facet_vars <- setdiff(facet_vars, names(predict_vars))

  labeled_vars <- unique(unlist(lapply(
    Filter(is_slice_text_layer, plot$layers),
    slice_text_label_vars, plot = plot
  )))

  held_vars <- setdiff(predictor_vars,
                       c(x_vars, group_vars, facet_vars, labeled_vars))
  held <- list()
  for (var in held_vars) {
    held[[var]] <- if (!is.null(predict_vars[[var]])) {
      predict_vars[[var]]
    } else {
      # geom_slice() already announced the imputed value; don't repeat it
      suppressMessages(impute_value(raw_data[[var]], var))
    }
  }
  held
}

# The "held at: x2 = 2.507; g = \"A\"" line from a named list of held values.
# Values format like geom_slice's console messages (4 sig figs, quoted
# strings); multi-value variables join with ", " (e.g. "x2 = 0, 4").
slice_subtitle_held_line <- function(held) {
  parts <- vapply(names(held), function(v) {
    paste0(v, " = ", paste(vapply(held[[v]], format_value, character(1)),
                           collapse = ", "))
  }, character(1))
  paste0("held at: ", paste(parts, collapse = "; "))
}


# Adding to a plot is the only moment geom_slice_subtitle() can see the
# geom_slice() layers it describes — and the subtitle belongs to the plot,
# not to any layer.
#' @export
#' @noRd
ggplot_add.slice_subtitle_spec <- function(object, plot, ...) {
  slice_layers <- Filter(is_slice_layer, plot$layers)

  if (length(slice_layers) == 0) {
    slice_warn(
      what = "geom_slice_subtitle() found no geom_slice() layer to describe, so no subtitle was added.",
      hint = "Add the slice first, such as 'geom_slice(model) + geom_slice_subtitle()'."
    )
    return(plot)
  }

  models <- lapply(slice_layers, function(l) l$stat_params$model)
  if (!all(vapply(models[-1], identical, logical(1), y = models[[1]]))) {
    names <- unique(vapply(slice_layers,
                           function(l) l$stat_params$model_name %||% "model",
                           character(1)))
    slice_warn(
      what = paste0("geom_slice_subtitle() found geom_slice() layers with different models (",
                    paste0("`", names, "`", collapse = ", "),
                    "), so no subtitle was added."),
      hint = "Use the same model in every geom_slice() layer, or remove the layers whose model differs."
    )
    return(plot)
  }

  model <- models[[1]]
  held <- slice_subtitle_held(plot, slice_layers, model)
  equation <- lm_equation(model)

  if (is.function(object$format)) {
    subtitle <- object$format(equation, held)
  } else {
    lines <- character(0)
    if (isTRUE(object$model)) lines <- equation
    if (length(held) > 0) lines <- c(lines, slice_subtitle_held_line(held))
    if (length(lines) == 0) return(plot)
    subtitle <- paste0(object$prepend,
                       paste(lines, collapse = "\n"),
                       object$append)
  }

  plot + labs(subtitle = subtitle)
}


#' Describe the lines drawn by geom_slice() in the plot subtitle
#'
#' `geom_slice_subtitle()` fills the plot subtitle with a description of the
#' plot's [geom_slice()] layers: the model equation ([lm_equation()] style) on
#' the first line, and the held values the plot does not otherwise show on the
#' second (`"held at: x2 = 2.507"`, formatted like `geom_slice()`'s console
#' messages).
#'
#' It takes no `model` or `predict_vars` — everything is borrowed from the
#' plot's existing `geom_slice()` layers, so add it *after* them (and after
#' any [geom_slice_text()]). The held-values line is conscious of what the
#' plot already labels: variables labeled by `geom_slice_text()`, pinned by a
#' grouping aesthetic (the legend covers those), or pinned by faceting are
#' left out. User-chosen `predict_vars` values and imputed defaults are
#' treated the same — both are unlabeled held values. When nothing is held,
#' the line is dropped entirely.
#'
#' @param model If `TRUE` (default), the subtitle's first line is the model
#'   equation; `FALSE` drops it, leaving only the held-values line.
#' @param prepend,append Plain strings pasted before the first line and after
#'   the last line of the default subtitle.
#' @param format A function of `(equation, values)` — the ready-made equation
#'   string and the named list of unlabeled held values — returning the whole
#'   subtitle. When given, it fully replaces the default layout (`model`,
#'   `prepend`, and `append` are ignored).
#'
#' @returns An object that sets the plot subtitle when added to a ggplot.
#'
#' @examples
#' \dontrun{
#' model <- lm(y ~ x + x2, data = dat)
#' ggplot(dat, aes(x, y)) +
#'   geom_point() +
#'   geom_slice(model) +
#'   geom_slice_subtitle()
#' }
#'
#' @export
geom_slice_subtitle <- function(model = TRUE,
                                prepend = "",
                                append = "",
                                format = NULL) {
  if (!is.logical(model) || length(model) != 1 || is.na(model)) {
    slice_abort(
      what = "`model` must be TRUE or FALSE.",
      hint = "For example, 'model = FALSE' to drop the equation line."
    )
  }
  if (!is.character(prepend) || length(prepend) != 1 || is.na(prepend)) {
    slice_abort(
      what = "`prepend` must be a single string.",
      hint = "For example, 'prepend = \"Model: \"'."
    )
  }
  if (!is.character(append) || length(append) != 1 || is.na(append)) {
    slice_abort(
      what = "`append` must be a single string.",
      hint = "For example, 'append = \" (mean-imputed)\"'."
    )
  }
  if (!is.null(format) && !is.function(format)) {
    slice_abort(
      what = "`format` must be a function of (equation, values).",
      hint = "For example, 'format = function(equation, values) equation'."
    )
  }
  structure(
    list(model = model, prepend = prepend, append = append, format = format),
    class = "slice_subtitle_spec"
  )
}
