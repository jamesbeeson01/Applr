# CASE: text_lm_equation_styles
# lm_equation() on a model with a factor and an interaction, in each style.
# The three strings are judged together as text.

model <- lm(Sepal.Length ~ Sepal.Width * Species, data = iris)
equations <- c(
  prettier = lm_equation(model),
  brackets = lm_equation(model, style = "brackets"),
  raw = lm_equation(model, style = "raw")
)

covers("lm_equation.format", "lm_equation.style", "lm_equation.terms-from-coefficients")
judged_output("equations", equations, type = "returned_text")

test_that("each style names the factor terms its own way", {
  expect_match(equations[["prettier"]], '(Species="versicolor")', fixed = TRUE)
  expect_match(equations[["prettier"]], 'Sepal.Width:(Species="virginica")', fixed = TRUE)
  expect_match(equations[["brackets"]], "*[versicolor]", fixed = TRUE)
  expect_match(equations[["raw"]], "*Speciesversicolor", fixed = TRUE)
  expect_equal(lm_equation(model, style = "b"), equations[["brackets"]])
})

test_that("the equation starts with the response and the rounded intercept", {
  co <- coef(model)
  expect_match(equations[["raw"]], paste0("^Sepal.Length = ", signif(co[[1]], 3), " "))
  expect_false(grepl("+ -", equations[["raw"]], fixed = TRUE))
})
