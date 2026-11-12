# Built data of a plot's `which`-th geom_slice() layer, read with messages
# silenced: imputation and back-transform messages are condition cases' job.
slice_data <- function(p, which = 1) {
  i <- which(vapply(p$layers, function(l) inherits(l$stat, "StatSlice") &&
                      !inherits(l$stat, "StatSliceText"), TRUE))[which]
  suppressMessages(ggplot2::layer_data(p, i))
}

# Built data of a plot's geom_slice_text() layers, stacked.
slice_text_data <- function(p) {
  i <- which(vapply(p$layers, function(l) inherits(l$stat, "StatSliceText"), TRUE))
  do.call(rbind, lapply(i, function(k) suppressMessages(ggplot2::layer_data(p, k))))
}

# The model's prediction on a grid, as an unnamed vector.
predicted <- function(model, newdata, ...) unname(stats::predict(model, newdata, ...))

# A plot's subtitle (or caption) once every layer has been added, with the
# messages its construction raises silenced.
annotation_of <- function(p, what = "subtitle") p$labels[[what]]
