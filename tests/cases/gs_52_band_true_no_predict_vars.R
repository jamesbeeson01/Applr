# CASE: gs_52_band_true_no_predict_vars
# TYPE: visual
# FUNC: geom_slice
# EXPECT: band = TRUE with NO predict_vars at all. The model has exactly one
#         non-axis predictor (x_pos), so it is unambiguous which variable
#         bands: x_pos, spanning its observed min/max from the data. Two
#         skyblue edge lines at those extremes with a translucent skyblue
#         ribbon between them — identical result to gs_50's band = "x_pos",
#         including the same console message (band range for x_pos imputed
#         from the min/max data range).

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
  geom_slice(model, band = TRUE)
