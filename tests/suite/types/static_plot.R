# Static ggplot (spec: "Static ggplot"). One state, the plot as printed. The
# plot is wrapped in a function so vdiffr keeps the theme users see rather
# than applying theme_test().

register_output_type(
  "static_plot",
  detect = function(x) inherits(x, "ggplot"),
  states = function(declared) list(plot = NULL),
  serialise = function(plot, states) {
    svg <- svg_form(function() print(plot))
    list(parts = list(main = svg$lines), engine_version = svg$engine_version, view = plot)
  },
  render = function(plot, state, file, live) png_view(file, function() print(plot)),
  view = "image",
  format = "png",
  demo = "single_predictor_line",
  mutations = list(
    title = function(x) { x$object <- x$object + ggplot2::labs(title = "Mutated"); x },
    theme = function(x) {
      x$object <- x$object + ggplot2::theme(panel.grid = ggplot2::element_blank())
      x
    },
    data = function(x) {
      d <- x$object$data
      col <- names(Filter(is.numeric, d))[1]
      d[[col]][1] <- d[[col]][1] + 1
      x$object$data <- d
      x
    },
    layer = function(x) { x$object <- x$object + ggplot2::geom_hline(yintercept = 0); x }
  )
)
