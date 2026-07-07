# CASE: ap_07_err_no_data_argument
# TYPE: console
# FUNC: autoplot
# EXPECT: A friendly error telling the user to refit with a data argument,
#         such as 'lm(y ~ x, data = your_data)'. The model has no $call$data,
#         so autoplot builds ggplot(NULL) and the aes() lookups can find the
#         vectors only by luck of scoping. Currently surfaces as an internal
#         "object not found" / aesthetics error at print time.

source("testing/_setup.R")
set.seed(123)

# local() so the vectors are gone by plot time, as they would be for a model
# fitted inside any function — autoplot's aes() cannot see them.
model <- local({
  height_cm <- runif(30, 150, 190)
  weight_kg <- 0.9 * height_cm + rnorm(30, 0, 5)
  lm(weight_kg ~ height_cm)
})

try_show(autoplot(model))
