# CASE: num_misc
# Smaller computed outputs: raw variables recovered from transformed terms,
# add_slice_2d(), the raw StatSlice layer, a glm, lm_latex()'s return and
# diagnose()'s graphical parameters.

covers("shared.model-data.raw-variables", "add_slice_2d.line-is-prediction",
       "ggproto_objects.raw-layer", "shared.validation.glm", "lm_latex.prints-and-returns",
       "diagnose.restores-par")

test_that("a transformed term slices along its raw variable", {
  m <- lm(mpg ~ I(wt^2) + log(hp), mtcars)
  d <- slice_data(ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(m, n = 10))
  expect_equal(d$y, predicted(m, data.frame(wt = d$x, hp = mean(mtcars$hp))))
})

test_that("add_slice_2d() draws on the current plot the line slice_2d() would", {
  m <- lm(mpg ~ disp + hp, mtcars)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  plot(mpg ~ disp, data = mtcars)
  usr <- graphics::par("usr")
  expect_silent(add_slice_2d(m, x_axis = "disp", hp = 150))
  expect_equal(graphics::par("usr"), usr)
  a <- prepare_slice_data(m, "disp", 100, TRUE, "none", list(hp = 150), fn = "add_slice_2d")
  b <- prepare_slice_data(m, "disp", 100, TRUE, "none", list(hp = 150), fn = "slice_2d")
  expect_equal(a$line, b$line)
  expect_equal(a$line$fit, predicted(m, data.frame(disp = a$line$x, hp = 150)))
})

test_that("a raw layer() with StatSlice draws what geom_slice() draws", {
  m <- lm(mpg ~ disp + hp + cyl, mtcars)
  base <- ggplot2::ggplot(mtcars, ggplot2::aes(disp, mpg))
  raw <- base + ggplot2::layer(stat = StatSlice, geom = GeomSlice, position = "identity",
                               inherit.aes = TRUE,
                               params = list(model = m, predict_vars = list(hp = 110),
                                             mapping = ggplot2::aes(disp, mpg)))
  layered <- base + geom_slice(m, predict_vars = list(hp = 110))
  expect_equal(slice_data(raw)[c("x", "y")], slice_data(layered)[c("x", "y")])
})

test_that("a glm is sliced on the link scale", {
  m <- glm(am ~ wt, family = binomial, data = mtcars)
  d <- slice_data(ggplot2::ggplot(mtcars, ggplot2::aes(wt, am)) + geom_slice(m, n = 10))
  expect_equal(d$y, predicted(m, data.frame(wt = d$x)))
})

test_that("lm_latex() prints its string and returns it invisibly", {
  m <- lm(mpg ~ wt, mtcars)
  out <- capture.output(v <- withVisible(lm_latex(m)))
  expect_false(v$visible)
  expect_equal(out, v$value)
  expect_match(v$value, "^\\$\\$.*\\$\\$$")
})

test_that("diagnose() restores mfrow", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  graphics::par(mfrow = c(2, 2))
  diagnose(lm(mpg ~ wt, mtcars))
  expect_equal(graphics::par("mfrow"), c(2, 2))
})
