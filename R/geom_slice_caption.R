# geom_slice_caption() — the plot-caption twin of geom_slice_subtitle().
#
# Everything (finding the slice layers, held-value/band logic, line
# formatting, validation) is shared with geom_slice_subtitle.R via
# slice_annotation_text() and new_slice_annotation_spec(); this file only
# routes the text to labs(caption = ...). Captions are right-aligned by
# ggplot2's default themes, so no alignment handling is needed here.


#' @export
#' @noRd
ggplot_add.slice_caption_spec <- function(object, plot, ...) {
  caption <- slice_annotation_text(object, plot, "geom_slice_caption",
                                   "caption")
  if (is.null(caption)) return(plot)
  plot + labs(caption = caption)
}


#' Describe the lines drawn by geom_slice() in the plot caption
#'
#' `geom_slice_caption()` is [geom_slice_subtitle()] for the plot caption: it
#' fills the caption (right-aligned in ggplot2's default themes) with the
#' model equation and the held values the plot does not otherwise show. All
#' behavior — what is reported, what is skipped because the legend, facets,
#' or [geom_slice_text()] already label it, and every parameter — matches
#' [geom_slice_subtitle()]; see its documentation for the details.
#'
#' @inheritParams geom_slice_subtitle
#'
#' @returns An object that sets the plot caption when added to a ggplot.
#'
#' @seealso [geom_slice_subtitle()] for the full documentation of what is
#'   reported; [geom_slice()] for the layers being described;
#'   [geom_slice_text()] to label the lines themselves.
#'
#' @examples
#' library(ggplot2)
#'
#' # Caption reports the model equation and that hp is held at its mean
#' model <- lm(mpg ~ disp + hp, data = mtcars)
#' ggplot(mtcars, aes(disp, mpg)) +
#'   geom_point() +
#'   geom_slice(model) +
#'   geom_slice_caption()
#'
#' @export
geom_slice_caption <- function(model = TRUE,
                               prepend = "",
                               append = "",
                               format = NULL) {
  new_slice_annotation_spec(model, prepend, append, format,
                            class = "slice_caption_spec")
}
