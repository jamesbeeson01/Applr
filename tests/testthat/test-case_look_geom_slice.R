# CASE: look_geom_slice
# How geom_slice() lines and ribbons look: the default skyblue line, fixed
# aesthetics, ribbons in their own line's colour, a fill that overrides it,
# and the confidence and prediction ribbons side by side in width.

mpg <- ggplot2::mpg
iris_model <- lm(Sepal.Length ~ Sepal.Width + Petal.Length, data = iris)
quad <- lm(hwy ~ displ + I(displ^2), data = mpg)
grouped <- lm(hwy ~ displ + I(displ^2) + displ:drv, data = mpg)
points <- function(data, mapping) ggplot2::ggplot(data, mapping) + ggplot2::geom_point()

default <- points(iris, ggplot2::aes(Petal.Length, Sepal.Length)) + geom_slice(iris_model) +
  ggplot2::labs(title = "Default line")
styled <- points(iris, ggplot2::aes(Petal.Length, Sepal.Length)) +
  geom_slice(iris_model, colour = "firebrick", linewidth = 2, linetype = "dashed") +
  ggplot2::labs(title = "colour, linewidth and linetype set")
confidence <- points(mpg, ggplot2::aes(displ, hwy)) + geom_slice(quad, interval = "confidence") +
  ggplot2::labs(title = "Confidence interval")
prediction <- points(mpg, ggplot2::aes(displ, hwy)) + geom_slice(quad, interval = "prediction") +
  ggplot2::labs(title = "Prediction interval")
ribbon_per_group <- points(mpg, ggplot2::aes(displ, hwy, colour = drv)) +
  geom_slice(grouped, interval = "confidence") + ggplot2::labs(title = "Ribbons follow their line's colour")
fill_set <- points(mpg, ggplot2::aes(displ, hwy, colour = drv)) +
  geom_slice(grouped, interval = "confidence", fill = "grey50") + ggplot2::labs(title = "fill = \"grey50\" wins")
full_range <- points(mpg, ggplot2::aes(displ, hwy, colour = drv)) + geom_slice(grouped, full_range = TRUE) +
  ggplot2::labs(title = "full_range = TRUE")

covers("geom_slice.default-look", "geom_slice.fixed-aesthetics", "geom_slice.ribbon-follows-line",
       "shared.intervals.look")
judged_output("default", default)
judged_output("styled", styled)
judged_output("confidence", confidence)
judged_output("prediction", prediction)
judged_output("ribbon_per_group", ribbon_per_group)
judged_output("fill_set", fill_set)
judged_output("full_range", full_range)

test_that("ribbons take the line's colour unless fill is set", {
  # The swap happens as the ribbon is drawn
  d <- slice_data(ribbon_per_group)
  expect_equal(slice_ribbon_fill(d, GeomSlice$default_aes$fill), d$colour)
  expect_equal(unique(slice_data(fill_set)$fill), "grey50")
  expect_equal(unique(slice_data(default)$colour), "skyblue")
})
