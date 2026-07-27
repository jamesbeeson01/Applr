# CASE: ap_05_factor_imputed
# TYPE: visual
# FUNC: autoplot
# EXPECT: iris scatter (Petal.Length vs Sepal.Length) with ONE straight
#         upward line. The factor Species is invisible on the plot, so
#         geom_slice imputes its most common level ("setosa", console
#         message); with the setosa intercept the line runs through the
#         setosa cluster and sits above the point cloud at large petal
#         lengths. No grouping into three lines.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Petal.Length + Species, data = iris)

p <- autoplot(model, summary = FALSE) +
  labs(title = "ap_05: autoplot(lm), factor covariate (Sepal.Length ~ Petal.Length + Species)",
       subtitle = "EXPECT: one line, Species imputed to \"setosa\"")
p
