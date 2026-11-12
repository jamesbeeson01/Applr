# CASE: text_labels
# The label strings geom_slice_text() writes, in each style and from each
# source, judged as text together.

set.seed(123)
d <- data.frame(x = runif(80, -10, 10), x2 = runif(80, 0, 4),
                g = factor(sample(c("A", "B"), 80, replace = TRUE)))
d$y <- d$x * ifelse(d$g == "A", 0.5, 2) + ifelse(d$g == "A", 5, -5) + 4 * d$x2 + rnorm(80)
model <- lm(y ~ x * g + x2, data = d)
crossed <- function(...) {
  ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    geom_slice(model, predict_vars = list(x2 = c(0, 2.123456), g = c("A", "B"))) + geom_slice_text(...)
}
labels_of <- function(p) paste(sort(slice_text_data(suppressMessages(p))$label), collapse = "\n")
key_of <- function(p) {
  p <- suppressMessages(p)
  layer <- Filter(function(l) inherits(l$geom, "GeomText") && !inherits(l$geom, "GeomSliceText"), p$layers)
  if (length(layer)) layer[[1]]$aes_params$label else ""
}

examples <- c(
  variable = labels_of(crossed()),
  value = labels_of(crossed(style = "value")),
  legend = labels_of(crossed(style = "legend")),
  legend_key = key_of(crossed(style = "legend")),
  group = labels_of(ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
                      geom_slice(model) + geom_slice_text()),
  # Any predict_vars entry wins over the group, even a single value, so both
  # lines read the same
  group_and_single_value = labels_of(ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
                                       geom_slice(model, predict_vars = list(x2 = 2)) + geom_slice_text()),
  group_and_values = labels_of(ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
                                 geom_slice(model, predict_vars = list(x2 = c(0, 4))) + geom_slice_text())
)

covers("geom_slice_text.label-predict-vars", "geom_slice_text.label-group", "geom_slice_text.style")
judged_output("labels", examples, type = "returned_text")

test_that("labels name the values, crossed in predict_vars order, to 4 significant figures", {
  expect_equal(strsplit(examples[["variable"]], "\n")[[1]],
               c("x2: 0; g: A", "x2: 0; g: B", "x2: 2.123; g: A", "x2: 2.123; g: B"))
  expect_equal(strsplit(examples[["value"]], "\n")[[1]], c("0; A", "0; B", "2.123; A", "2.123; B"))
  expect_equal(examples[["legend"]], examples[["value"]])
  expect_equal(examples[["legend_key"]], "labels: x2; g")
})

test_that("with no predict_vars variation labels name the group; predict_vars win otherwise", {
  expect_equal(strsplit(examples[["group"]], "\n")[[1]], c("g: A", "g: B"))
  expect_equal(strsplit(examples[["group_and_single_value"]], "\n")[[1]], c("x2: 2", "x2: 2"))
  expect_equal(strsplit(examples[["group_and_values"]], "\n")[[1]], c("x2: 0", "x2: 0", "x2: 4", "x2: 4"))
})
