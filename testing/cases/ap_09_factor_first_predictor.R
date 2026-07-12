# CASE: ap_09_factor_first_predictor
# TYPE: console
# FUNC: autoplot
# EXPECT: The model's FIRST predictor is the factor Species, which cannot go
#         on geom_slice's continuous x-axis, so autoplot chooses the first
#         numeric predictor (Petal.Length) instead and says so (message with
#         an 'x_axis =' hint). Species is then invisible on the plot, so
#         geom_slice imputes its most common level ("setosa", message).
#         The plot itself renders fine (same picture as ap_05).

source("testing/_setup.R")

model <- lm(Sepal.Length ~ Species + Petal.Length, data = iris)

try_show(autoplot(model))
