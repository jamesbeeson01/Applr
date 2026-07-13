# CASE: cp_02_band_and_held
# TYPE: visual
# FUNC: geom_slice_caption
# EXPECT: The caption twin of sb_13. A projection band on x2 (1 to 4) with a
#         THIRD predictor x3 pinned at a single value (2). The CAPTION
#         (bottom-right, right-aligned) reports both, each with its own
#         wording: line 1 the model equation, line 2 "held at: x3 = 2",
#         line 3 "projection: x2 spanning 1-4". Pinned values keep the
#         "held at:" wording; only the banded variable uses "spanning".

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
x3 <- runif(n, 0, 4)
y <- x + 2 * x2 + x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(1, 4), x3 = 2), band = "x2") +
  geom_slice_caption() +
  labs(title = "cp_02: held value and span reported in the caption")
p
