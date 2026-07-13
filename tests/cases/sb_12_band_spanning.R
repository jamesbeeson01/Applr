# CASE: sb_12_band_spanning
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: One projection band (x2 from 1 to 4, band = TRUE) on a skyblue
#         slice pair. The subtitle reports the banded variable with range
#         wording instead of the pinned-value wording: line 1 the model
#         equation, line 2 "projection: x2 spanning 1-4". Variables pinned
#         to a single value would still use the "held at:" wording.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(1, 4)), band = TRUE) +
  geom_slice_subtitle() +
  labs(title = "sb_12: banded variable reported as 'spanning' in the subtitle")
p
