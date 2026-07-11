# CASE: gs_50_band_imputed_range
# TYPE: visual
# FUNC: geom_slice
# EXPECT: A projection band with NO values pinned by the user: band = "x_pos"
#         with x_pos absent from predict_vars imputes the band range from the
#         data — the observed min and max of x_pos. Two skyblue edge lines at
#         those imputed extremes with a translucent skyblue ribbon between
#         them. The band should be wider than gs_49's (full data range, not
#         1-9).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_slice(model, band = "x_pos")
