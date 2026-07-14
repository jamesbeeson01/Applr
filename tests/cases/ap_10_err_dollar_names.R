# CASE: ap_10_err_dollar_names
# TYPE: console
# FUNC: autoplot
# EXPECT: The friendly geom_slice dollar-names error ("Models with `$` in
#         their variable names are not supported... refit using the data
#         argument"). autoplot's own all.vars()/eval() handling of a
#         $-style model must not crash with a less helpful error first.

source("tests/_setup.R")

model <- lm(mtcars$mpg ~ mtcars$disp)

try_show(autoplot(model))
