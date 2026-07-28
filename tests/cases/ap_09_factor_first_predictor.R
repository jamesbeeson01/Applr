# CASE: ap_09_factor_first_predictor
# TYPE: console
# FUNC: autoplot
# EXPECT: The model's FIRST predictor is the factor Species, which cannot go
#         on geom_slice's continuous x-axis, so autoplot chooses the first
#         numeric predictor (Petal.Length) instead and says so (message with
#         a 'mapping = aes(x = ...)' hint). Species is a non-numeric predictor,
#         so autoplot then shows it as colour (message) — one line per species
#         rather than imputing it. The plot renders fine (same picture as ap_05).

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Species + Petal.Length, data = iris)

try_show(autoplot(model, summary = FALSE))
