# CASE: num_imputation
# The value each engine holds an unshown predictor at, and that the line is
# predicted at exactly that value.

covers("shared.imputation.values", "shared.imputation.base-values",
       "shared.imputation.na-values", "shared.imputation.factor-in-formula",
       "shared.imputation.engines-differ")

df <- data.frame(
  x = 1:9,
  num = c(3, 1, 4, 1, 5, 9, 2, 6, 14),
  fac = factor(c("a", "b", "b", "c", "c", "c", "a", "b", "c"), levels = c("a", "b", "c")),
  chr = c("p", "q", "q", "q", "p", "q", "p", "q", "q"),
  y = c(3, 5, 4, 8, 9, 12, 10, 13, 16)
)

test_that("geom_slice() holds numeric at the mean and factor or character at the most common value", {
  m <- lm(y ~ x + num + fac + chr, data = df)
  d <- slice_data(ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_slice(m, n = 9))
  held <- data.frame(x = d$x, num = mean(df$num), fac = factor("c", levels(df$fac)), chr = "q")
  expect_equal(d$y, predicted(m, held))
})

test_that("missing values are ignored when imputing", {
  na_df <- df
  na_df$num[1] <- NA
  m <- lm(y ~ x + num, data = na_df)
  d <- slice_data(ggplot2::ggplot(na_df, ggplot2::aes(x, y)) + geom_slice(m, n = 9))
  expect_equal(d$y, predicted(m, data.frame(x = d$x, num = mean(na_df$num, na.rm = TRUE))))
})

test_that("slice_2d() holds numeric at the mean and factor at the first level", {
  # The engines differ here (for_devs/known_issues.Rmd): geom_slice() would
  # hold fac at its most common level, "c". This pins each engine's choice.
  m <- lm(y ~ x + num + fac, data = df)
  prep <- suppressMessages(prepare_slice_data(m, "x", 9, TRUE, "none", list()))
  expect_equal(prep$other_vals, list(num = mean(df$num), fac = "a"))
  expect_equal(prep$line$fit, predicted(m, data.frame(x = prep$line$x, num = mean(df$num), fac = "a")))
})

test_that("a predictor converted in the formula draws no line today (known bug)", {
  # KNOWN BUG (for_devs/known_issues.Rmd): factor(cyl) is imputed with the
  # mean of the raw cyl, which predict() rejects. When this expectation fails,
  # the bug is fixed: rewrite it to expect the line predicted at a level.
  m <- lm(mpg ~ wt + factor(cyl), data = mtcars)
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(m)
  r <- conditions_of(function() p)
  expect_equal(r$kinds, c("message", "warning"))
  expect_match(r$messages[2], "predict() failed for this slice", fixed = TRUE)
  expect_equal(nrow(r$value$data[[1]]), 0)
})
