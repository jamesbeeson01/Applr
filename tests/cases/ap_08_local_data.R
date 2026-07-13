# CASE: ap_08_local_data
# TYPE: console
# FUNC: autoplot
# EXPECT: No output at all. autoplot recovers the model's data via the
#         formula environment (geom_slice's slice_model_frame()), so a model
#         fitted to data that is not in autoplot's own scope still plots —
#         no errors, warnings, or messages.

source("testing/_setup.R")
set.seed(123)

# The data frame lives only in the local() scope, like data created inside a
# function. Both autoplot and geom_slice recover it via the formula environment.
model <- local({
  class_data <- data.frame(x = runif(30, 0, 10))
  class_data$y <- 2 * class_data$x + rnorm(30)
  lm(y ~ x, data = class_data)
})

try_show(autoplot(model))
