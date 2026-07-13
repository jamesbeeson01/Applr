# CASE: le_11_mtcars_log
# TYPE: console
# FUNC: lm_equation
# EXPECT: Real-data equation with a negative slope rendered via "- " (not
#         "+ -"): "log(mpg) = 3.45 - 0.00212*disp".

source("tests/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

try_show(lm_equation(model))
