# CASE: gs_55_warn_band_var_on_x_axis
# TYPE: visual
# FUNC: geom_slice
# EXPECT: A clear, student-readable warning: band = "x" names the predictor on
#         the plot's x-axis, which already varies along the line, so it
#         cannot band and no band is drawn. The hint should name predictors a
#         band could actually use (here x_pos) and offer band = TRUE to choose
#         automatically. The slice line still draws — no further errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

try_show(ggplot(dat, aes(x, y)) +
           geom_point() +
           geom_slice(model, band = "x"))
