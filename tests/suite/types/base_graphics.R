# Base graphics (spec: "Base graphics"). The object is the drawing code as a
# function; one state, the device contents after it runs. A function alone
# could also be a call whose conditions are judged, so the type is declared.

register_output_type(
  "base_graphics",
  states = function(declared) list(plot = NULL),
  serialise = function(draw, states) {
    stopifnot(is.function(draw))
    svg <- svg_form(draw)
    list(parts = list(main = svg$lines), engine_version = svg$engine_version, view = draw)
  },
  render = function(draw, state, file, live) png_view(file, draw),
  view = "image",
  format = "png",
  demo = "base_slice_2d",
  mutations = list(
    annotation = function(x) { f <- x$object; x$object <- function() { f(); graphics::abline(h = 0) }; x },
    title = function(x) { f <- x$object; x$object <- function() { f(); graphics::title(sub = "Mutated") }; x },
    margins = function(x) {
      f <- x$object
      x$object <- function() { graphics::par(mar = c(6, 6, 2, 2)); f() }
      x
    }
  )
)
