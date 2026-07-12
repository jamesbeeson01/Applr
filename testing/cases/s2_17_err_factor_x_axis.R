# CASE: s2_17_err_factor_x_axis
# TYPE: console
# FUNC: slice_2d
# EXPECT: A clear error explaining the x-axis must be numeric:
#         "`x_axis` must be numeric; the class \"factor\" is not supported."

source("testing/_setup.R")

mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + hp, data = mtcars2)

try_show(slice_2d(model, x_axis = "cyl"))
