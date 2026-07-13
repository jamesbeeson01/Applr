# CASE: gs_53_warn_band_nothing_to_band
# TYPE: visual
# FUNC: geom_slice
# EXPECT: A clear, student-readable warning: band = TRUE but the model has no
#         variable to band — y ~ x uses the x-axis variable as its only
#         predictor, so there is nothing to span. The warning should name the
#         problem, say no band is drawn, and hint that a band needs a second
#         predictor (or a band = "variable" choice). The slice line still
#         draws — no further errors.

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
