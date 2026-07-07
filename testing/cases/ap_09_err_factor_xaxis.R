# CASE: ap_09_err_factor_xaxis
# TYPE: console
# FUNC: autoplot
# EXPECT: The model's FIRST predictor is the factor Species, so autoplot puts
#         it on the x-axis and geom_slice's continuous-x-axis check fires.
#         The message should reach the user clearly (currently wrapped in
#         ggplot2's stat computation warning); Petal.Length is imputed at its
#         mean first (message). Ideally autoplot would choose a numeric
#         predictor for the x-axis instead.

source("testing/_setup.R")

model <- lm(Sepal.Length ~ Species + Petal.Length, data = iris)

try_show(autoplot(model))
