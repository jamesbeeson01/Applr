# CASE: ap_07_err_no_data_argument
# TYPE: console
# FUNC: autoplot
# EXPECT: A friendly error telling the user to refit with a data argument,
#         such as 'lm(y ~ x, data = your_data)'. The model has no $call$data,
#         and recovering the vectors from the fitting scope only works by
#         luck (here they are gone by plot time), so autoplot refuses up
#         front instead of building a broken plot.

source("tests/_setup.R")
set.seed(123)

# local() so the vectors are gone by plot time, as they would be for a model
# fitted inside any function — autoplot must refuse rather than guess.
model <- local({
  height_cm <- runif(30, 150, 190)
  weight_kg <- 0.9 * height_cm + rnorm(30, 0, 5)
  lm(weight_kg ~ height_cm)
})

try_show(autoplot(model, summary = FALSE))
