# CASE: ap_13_summary_console
# TYPE: visual
# FUNC: autoplot
# EXPECT: By default autoplot(lm) prints summary(model) to the console BEFORE
#         the plot, so you can refit and read coefficients from the same call.
#         Console output = the model summary (call, residuals, coefficients,
#         R-squared, F-statistic). A plot is also produced (mpg ~ disp scatter
#         with a straight downward line) — its appearance is ap_01's concern.

source("tests/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

p <- autoplot(model)
p
