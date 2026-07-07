# CASE: gs_48_err_discrete_xaxis
# TYPE: console
# FUNC: geom_slice
# EXPECT: A factor predictor mapped to the x-axis makes the x scale discrete;
#         geom_slice needs a continuous axis to draw a line. A clear error:
#         "geom_slice() needs a continuous x-axis, but the x scale is
#         discrete." (imputation messages for the held variable may print
#         first).

source("testing/_setup.R")

mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + hp, data = mtcars2)

try_show(ggplot(mtcars2, aes(cyl, mpg)) +
           geom_point() +
           geom_slice(model))
