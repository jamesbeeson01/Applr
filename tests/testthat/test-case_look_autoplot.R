# CASE: look_autoplot
# autoplot()'s finished figures, from the README: the iris quick look,
# colour and facets chosen for it, a user mapping plus facet, a different
# x-axis with bare lines, and a composite x-axis that shows an exact fit.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ + drv + cyl, data = mpg)
build <- function(p) suppressMessages(p)
set.seed(123)
n <- 80
dat <- data.frame(x = runif(n, 0.1, 10), x2 = runif(n, 0.1, 10),
                  x3 = sample(c(1, 20, 40), n, replace = TRUE), x4 = sample(c(1, 2), n, replace = TRUE))
dat$y <- log(5 + dat$x + dat$x2 + dat$x3 + 1 / 5 * dat$x * dat$x3 + 80 * dat$x4)
exact <- lm(exp(y) ~ x * x3 + x2 + x4, data = dat)
zig <- data.frame(x = rep(1:10, 2), x2 = rep(c(1, 3), each = 10))
zig$y <- zig$x + 2 * zig$x2 + c(0.3, -0.2)[(1:20 %% 2) + 1]
zig_model <- lm(y ~ x + x2, data = zig)

iris_quick <- build(autoplot(lm(Petal.Length ~ Sepal.Length + I(Sepal.Length^2):Species, iris), summary = FALSE))
chosen <- build(autoplot(model, summary = FALSE))
mapped <- build(autoplot(model, ggplot2::aes(colour = factor(cyl)), summary = FALSE) + ggplot2::facet_wrap(~drv))
other_axis <- build(autoplot(model, ggplot2::aes(x = cyl, colour = factor(drv)), interval = "none", summary = FALSE) +
  ggplot2::labs(title = "The Same Model From a Different Angle"))
exact_composite <- ggplot2::ggplot(dat, ggplot2::aes(x = log(5 + x + x2 + x3 + 1 / 5 * x * x3 + 80 * x4), y)) +
  ggplot2::geom_point() + geom_slice(exact) + ggplot2::labs(title = "Same Model, Different X-Axis")
zigzag <- ggplot2::ggplot(zig, ggplot2::aes(x * x2, y)) + ggplot2::geom_point() + geom_slice(zig_model) +
  ggplot2::labs(title = "Predictions that aren't a function of x * x2")

covers("autoplot.looks-complete", "shared.composite-x.exact-fit", "shared.composite-x.zigzag")
judged_output("iris_quick", iris_quick)
judged_output("chosen", chosen)
judged_output("mapped", mapped)
judged_output("other_axis", other_axis)
judged_output("exact_composite", exact_composite)
judged_output("zigzag", zigzag)

test_that("the exact fit's points lie on its composite-axis line", {
  d <- slice_data(exact_composite)
  expect_equal(d$y, (dat$y[order(log(5 + dat$x + dat$x2 + dat$x3 + dat$x * dat$x3 / 5 + 80 * dat$x4))]),
               tolerance = 1e-6)
})
