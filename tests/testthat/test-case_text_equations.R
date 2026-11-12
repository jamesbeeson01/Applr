# CASE: text_equations
# lm_equation() and lm_latex() across representative models. Both outputs
# are judged as text; expectations check what each string must contain.

models <- list(
  simple = lm(mpg ~ wt, mtcars),
  multiple = lm(mpg ~ disp + hp, mtcars),
  transformed = lm(log(mpg) ~ wt + I(wt^2), mtcars),
  no_intercept = lm(mpg ~ 0 + wt, mtcars),
  rank_deficient = lm(mpg ~ wt + I(2 * wt), mtcars),
  exact_fit = lm(y ~ x, data.frame(x = 1:5, y = 2 * (1:5))),
  intercept_only = lm(mpg ~ 1, mtcars),
  underscore_name = lm(mpg ~ wt_lb, transform(mtcars, wt_lb = wt * 1000))
)
equations <- vapply(models, lm_equation, "")
latex <- vapply(models, function(m) {
  out <- capture.output(v <- lm_latex(m))
  v
}, "")

covers("lm_equation.format", "lm_equation.no-intercept", "lm_equation.na-and-residue",
       "lm_equation.intercept-only", "lm_latex.format", "lm_latex.special-characters")
judged_output("equations", equations, type = "returned_text")
judged_output("latex", latex, type = "returned_text")

test_that("coefficients are rounded to 3 significant figures and signs read naturally", {
  co <- signif(coef(models$multiple), 3)
  expect_equal(equations[["multiple"]],
               paste0("mpg = ", co[[1]], " - ", abs(co[["disp"]]), "*disp - ", abs(co[["hp"]]), "*hp"))
  expect_equal(equations[["transformed"]], sub("^", "", equations[["transformed"]]))
  expect_match(equations[["transformed"]], "^log\\(mpg\\) = .*\\*I\\(wt\\^2\\)$")
})

test_that("no intercept prints none; NA coefficients and residue are dropped", {
  expect_match(equations[["no_intercept"]], "^mpg = -?[0-9.]+\\*wt$")
  expect_false(grepl("NA", equations[["rank_deficient"]], fixed = TRUE))
  expect_equal(equations[["exact_fit"]], "y = 0 + 2*x")
})

test_that("an intercept-only model leaves an empty term today (known bug)", {
  # KNOWN BUG (for_devs/known_issues.Rmd): should be "mpg = 20.1".
  expect_equal(equations[["intercept_only"]], "mpg = 20.1 + *")
})

test_that("lm_latex() underbraces the prediction and each term, numbered from 1", {
  expect_match(latex[["multiple"]], "^\\$\\$\\\\underbrace\\{\\\\hat\\{Y_i\\}\\}_\\{\\\\text\\{Pred\\. mpg\\}\\} = ")
  expect_match(latex[["multiple"]], "\\\\underbrace\\{X_\\{1i\\}\\}_\\{\\\\text\\{disp\\}\\}")
  expect_match(latex[["multiple"]], "\\\\underbrace\\{X_\\{2i\\}\\}_\\{\\\\text\\{hp\\}\\}\\$\\$$")
})

test_that("a name with an underscore goes into \\text{} unescaped today (known issue)", {
  # LaTeX needs \_ inside \text{}; this pins today's output. When it fails,
  # the name is escaped: expect \\_ instead.
  expect_match(latex[["underscore_name"]], "\\text{wt_lb}", fixed = TRUE)
})
