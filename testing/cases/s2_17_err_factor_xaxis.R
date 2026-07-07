# CASE: s2_17_err_factor_xaxis
# TYPE: console
# FUNC: slice_2d
# EXPECT: A clear error explaining the x-axis must be numeric:
#         "`xaxis` must be numeric; the class \"factor\" is not supported."

source("testing/_setup.R")

mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + hp, data = mtcars2)

try_show(slice_2d(model, xaxis = "cyl"))
