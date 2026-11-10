# plotly 3D (spec: "plotly 3D"), from scatter_3d(). States are camera
# presets: layout.scene.camera values, applied only when a state is shown.

default_camera_presets <- list(
  default = list(eye = list(x = 1.25, y = 1.25, z = 1.25)),
  top = list(eye = list(x = 0, y = 0, z = 2.5)),
  side = list(eye = list(x = 2.5, y = 0, z = 0))
)

# uid and elementId change between builds and don't affect appearance.
drop_build_ids <- function(x) {
  if (!is.list(x)) return(x)
  x[c("uid", "elementId")] <- NULL
  lapply(x, drop_build_ids)
}

widget_dependencies <- function(widget) {
  deps <- c(htmlwidgets::getDependency(class(widget)[1], "plotly"), widget$dependencies)
  sort(vapply(deps, function(d) paste(d$name, d$version), ""))
}

register_output_type(
  "plotly_3d",
  detect = function(x) inherits(x, "plotly"),
  states = function(declared) declared %||% default_camera_presets,
  serialise = function(widget, states) {
    built <- with_pinned_options(plotly::plotly_build(widget))
    list(parts = list(
      figure = canonical_json(drop_build_ids(built$x[c("data", "layout", "config")])),
      presets = canonical_json(states),
      shell = widget_dependencies(built)
    ), view = built)
  },
  live = function(built, file) {
    hooked <- htmlwidgets::onRender(built, "function(el) {
      window.applrSetState = function(camera) {
        return Plotly.relayout(el, {'scene.camera': camera});
      };
      window.applrReady = true;
    }")
    save_live_widget(hooked, file)
  },
  render = function(built, state, file, live) screenshot_state(live, state, file),
  view = "states",
  format = "png",
  demo = "scatter_3d_two_predictors",
  mutations = list(
    layout = function(x) { x$object <- plotly::layout(x$object, title = "Mutated"); x },
    style = function(x) { x$object <- plotly::style(x$object, opacity = 0.5, traces = 1); x },
    preset = function(x) {
      x$states <- x$states %||% default_camera_presets
      x$states[[1]]$eye$z <- x$states[[1]]$eye$z + 0.1
      x
    },
    dependency = function(x) {
      x$object$dependencies <- c(x$object$dependencies, list(
        htmltools::htmlDependency("mutated", "1.0", src = c(href = "mutated"))))
      x
    }
  )
)
