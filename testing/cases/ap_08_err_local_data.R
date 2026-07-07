# CASE: ap_08_err_local_data
# TYPE: console
# FUNC: autoplot
# EXPECT: autoplot should recover the model's data via the formula
#         environment (as geom_slice's slice_model_frame() does), so a model
#         fitted to data that is not in autoplot's own scope should still
#         plot. Currently `eval(model$call$data)` looks up the data symbol in
#         autoplot.lm's environment and fails with an internal
#         "object 'class_data' not found" error.

source("testing/_setup.R")
set.seed(123)

# The data frame lives only in the local() scope, like data created inside a
# function. geom_slice() itself handles this; autoplot's eval() does not.
model <- local({
  class_data <- data.frame(x = runif(30, 0, 10))
  class_data$y <- 2 * class_data$x + rnorm(30)
  lm(y ~ x, data = class_data)
})

try_show(autoplot(model))
