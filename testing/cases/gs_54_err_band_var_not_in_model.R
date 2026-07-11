# CASE: gs_54_err_band_var_not_in_model
# TYPE: console
# FUNC: geom_slice
# EXPECT: A clear, student-readable error: band = "x3" names a variable that
#         exists in the data set but is NOT a predictor in the model, so the
#         model's predictions cannot vary with it and no band is possible.
#         The error should say the variable is not in the model and hint at
#         the model's actual predictors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
x3 <- runif(n, 0, 100)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, x3, y)
model <- lm(y ~ x + x_pos, data = dat)

try_show(ggplot(dat, aes(x, y)) +
           geom_point() +
           geom_slice(model, band = "x3"))
