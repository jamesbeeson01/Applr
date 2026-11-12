# CASE: cond_misc
# Conditions from the smaller functions: lm_equation()'s style, diagnose(),
# and the deprecated drawit() and defunct geom_fit().

on_device <- function(code) function() {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  code()
}

covers("lm_equation.bad-style", "diagnose.not-lm", "diagnose.few-rows", "geom_fit.errors-with-pointer",
       "drawit.warns-and-forwards", "drawit.no-xaxis")

raises("equation_bad_style", function() lm_equation(lm(mpg ~ wt, mtcars), style = "fancy"), "warning",
       'so "prettier" was used')
raises("diagnose_not_lm", function() diagnose(1), "error", "model must be an object of class 'lm'",
       format = FALSE)
raises("diagnose_three_rows", on_device(function() {
  diagnose(lm(y ~ x, data.frame(x = 1:3, y = c(1, 3, 2))))
}), character())
raises("geom_fit_defunct", function() geom_fit(lm(mpg ~ wt, mtcars)), "error",
       "`geom_fit()` has been removed; use `geom_slice()` instead.")
raises("drawit_deprecated", on_device(function() drawit(lm(mpg ~ wt + hp, mtcars), "hp", wt = 3)),
       "warning", "`drawit()` is deprecated; use `slice_2d()` instead.")
raises("drawit_no_xaxis", on_device(function() drawit(lm(mpg ~ disp, mtcars))),
       c("warning", "message"), "x_axis = \"wt\"")

test_that("drawit() draws what slice_2d() draws", {
  m <- lm(mpg ~ wt + hp, mtcars)
  a <- suppressWarnings(prepare_slice_data(m, "hp", 100, TRUE, "none", list(wt = 3)))
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  expect_warning(drawit(m, "hp", wt = 3, col = "red"), "deprecated")
  expect_equal(a$line$fit, predicted(m, data.frame(hp = a$line$x, wt = 3)))
})
