m_simple <- lm(mpg ~ disp, data = mtcars)

test_that("lm_equation() writes a plain-text equation", {
  expect_identical(lm_equation(m_simple), "mpg = 29.6 - 0.0412*disp")
  expect_identical(lm_equation(m_simple, style = "raw"), "mpg = 29.6 - 0.0412*disp")
})

test_that("lm_equation() keeps a transformed response on the left side", {
  m_log <- lm(log(mpg) ~ disp, data = mtcars)
  expect_identical(lm_equation(m_log), "log(mpg) = 3.45 - 0.00212*disp")
})

test_that("lm_equation() spells out factor levels", {
  m_factor <- lm(mpg ~ disp + factor(cyl), data = mtcars)
  eq <- lm_equation(m_factor)
  expect_match(eq, "factor(cyl)=\"6\"", fixed = TRUE)
  expect_match(eq, "factor(cyl)=\"8\"", fixed = TRUE)
})

test_that("lm_latex() returns display-math LaTeX", {
  tex <- NULL
  invisible(capture.output(tex <- lm_latex(m_simple)))
  expect_type(tex, "character")
  expect_match(tex, "^\\$\\$.*\\$\\$$")
  expect_match(tex, "\\hat{Y_i}", fixed = TRUE)
  expect_match(tex, "0.0412", fixed = TRUE)
})
