# CASE: condition_imputed_values
# geom_slice() on a three-predictor model with nothing held: each unheld
# predictor is imputed with a message, and the plot is still built. The
# messages' wording is judged.

model <- lm(mpg ~ wt + hp + qsec, data = mtcars)
call <- function() {
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() +
    geom_slice(model)
}

covers("shared.imputation.message")
judged_output("wording", call, type = "conditions")

test_that("each unheld predictor is imputed with a message and the plot still builds", {
  expect_message(expect_message(p <- ggplot2::ggplot_build(call()), "`hp`"), "`qsec`")
  expect_s3_class(p, "ggplot_built")
})
