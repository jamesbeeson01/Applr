# CASE: sb_02_predict_vars
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: One skyblue slice with x2 pinned by the USER via
#         predict_vars = list(x2 = 1). Nothing on the plot labels that choice,
#         so the default subtitle reports it: line 1 the model equation,
#         line 2 "held at: x2 = 1". User-specified predict_vars and imputed
#         values are treated the same — both are unlabeled held values.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = 1)) +
  geom_slice_subtitle() +
  labs(title = "sb_02: predict_vars value reported in the subtitle")
p
