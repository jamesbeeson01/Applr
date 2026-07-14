# CASE: sb_03_text_labeled_excluded
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Two skyblue slices (x2 at 0 and 4) labeled at their right ends by
#         geom_slice_text() ("x2: 0", "x2: 4"), plus a third predictor x3
#         imputed at its mean. The subtitle must be CONSCIOUS of what is
#         already labeled: x2 appears on the plot via geom_slice_text(), so
#         only x3 goes in the subtitle — line 1 the equation, line 2
#         "held at: x3 = <mean>". No mention of x2 in the subtitle.
#         Console message: x3 not specified, held at its mean (~-0.083).

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
x3 <- runif(n, -2, 2)
y <- x + 2 * x2 - x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text() +
  geom_slice_subtitle() +
  labs(title = "sb_03: x2 labeled on-plot, so only x3 in the subtitle")
p
