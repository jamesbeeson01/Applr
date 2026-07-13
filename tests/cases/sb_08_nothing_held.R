# CASE: sb_08_nothing_held
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Single-predictor model y ~ x: nothing is imputed or pinned, so
#         there is no held-values line at all. The default subtitle is just
#         the ONE equation line — no dangling "held at:" text, no blank
#         second line.

source("testing/_setup.R")
set.seed(123)

n <- 40
x <- runif(n, -10, 10)
y <- 2 * x + 3 + rnorm(n)
dat <- data.frame(x, y)
model <- lm(y ~ x, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_08: nothing held — equation line only")
p
