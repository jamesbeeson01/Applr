# CASE: ap_15_deprecated_xaxis
# TYPE: console
# FUNC: autoplot
# EXPECT: The deprecated `xaxis` argument still works but warns, pointing to
#         `mapping = aes(x = ...)`. It seeds the x aesthetic, so xaxis = "hp"
#         puts hp on the x-axis; disp is then invisible and geom_slice imputes
#         it at its mean (message). Output: the deprecation warning followed by
#         the disp imputation message.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

try_show(autoplot(model, xaxis = "hp", summary = FALSE))
