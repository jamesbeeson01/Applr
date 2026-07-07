# CASE: gs_16_factor_predictor
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mtcars scatter (disp vs mpg), model mpg ~ factor(cyl) + disp.
#         geom_slice called without predict_vars — cyl imputed to its most
#         common level ("8", 14 of 32 cars), reported by a console message.
#         One line corresponding to the cyl=8 slice.
#         Tests that geom_slice handles factor predictors without crashing.
#         No errors. (If it crashes, factor handling in predict() is the likely culprit.)

source("testing/_setup.R")

mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + disp, data = mtcars2)

p <- ggplot(mtcars2, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_16: Factor predictor — mpg ~ factor(cyl) + disp",
       subtitle = "EXPECT: One line at imputed cyl level (mode, 8). No crash on factor variable.")
p
