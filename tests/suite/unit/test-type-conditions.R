test_that("every condition is captured in order, including those raised while drawing", {
  call <- function() {
    message("first")
    warning("second")
    ggplot2::ggplot(data.frame(x = c(1, NA)), ggplot2::aes(x, x)) + ggplot2::geom_point()
  }
  form <- conditions_form(capture_conditions(call))
  expect_equal(form[1:5], c("message", "first", "", "warning", "second"))
  expect_equal(form[7], "warning")
  expect_match(form[8], "Removed 1 row")
})

test_that("an error ends the capture and is recorded", {
  form <- conditions_form(capture_conditions(function() { message("a"); stop("b"); message("c") }))
  expect_equal(form, c("message", "a", "", "error", "b"))
})

test_that("ANSI codes are removed and curly quotes become straight", {
  conds <- list(list(kind = "warning", message = "\033[31m‘x’\033[39m and “y”"))
  expect_equal(conditions_form(conds), c("warning", "'x' and \"y\""))
})
