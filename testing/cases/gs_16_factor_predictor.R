# gs_16_factor_predictor.R
# EXPECT: mtcars scatter (disp vs mpg), model mpg ~ factor(cyl) + disp.
#         geom_slice called without predict_vars — cyl should default to first level (4).
#         One line corresponding to the cyl=4 slice.
#         Tests that geom_slice handles factor predictors without crashing.
#         No errors. (If it crashes, factor handling in predict() is the likely culprit.)

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))

mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + disp, data = mtcars2)

p <- ggplot(mtcars2, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_16: Factor predictor — mpg ~ factor(cyl) + disp",
       subtitle = "EXPECT: One line at default cyl level (4). No crash on factor variable.")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_16_factor_predictor.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_16_factor_predictor.png")
