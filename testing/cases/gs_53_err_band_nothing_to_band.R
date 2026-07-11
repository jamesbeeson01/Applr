# CASE: gs_53_err_band_nothing_to_band
# TYPE: console
# FUNC: geom_slice
# EXPECT: A clear, student-readable error: band = TRUE but the model has no
#         variable to band — y ~ x uses the x-axis variable as its only
#         predictor, so there is nothing to span. The error should name the
#         problem and hint that a band needs a second predictor (or a
#         band = "variable" choice).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + rnorm(n)
dat <- data.frame(x, y)
model <- lm(y ~ x, data = dat)

try_show(ggplot(dat, aes(x, y)) +
           geom_point() +
           geom_slice(model, band = TRUE))
