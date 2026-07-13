# CASE: gs_54_warn_band_var_not_in_model
# TYPE: visual
# FUNC: geom_slice
# EXPECT: A clear, student-readable warning: band = "x3" names a variable that
#         exists in the data set but is NOT a predictor in the model, so no
#         band is possible. The warning should say the variable is not in the
#         model, say no band is drawn, and hint at predictors a band could
#         actually use (here x_pos, not the x-axis variable), plus band = TRUE
#         to choose automatically. The slice line still draws — no further
#         errors.

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
