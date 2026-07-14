# CASE: gs_49_band_two_values
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Two parallel skyblue lines (x_pos = 1 lower, x_pos = 9 upper) with a
#         translucent skyblue ribbon filling the region between them — a
#         projection band. band = TRUE spans the min and max values of the one
#         multi-value predict_vars variable; the edge lines still draw as
#         ordinary slices.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_slice(model, predict_vars = list(x_pos = c(1, 9)), band = TRUE)
