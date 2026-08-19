# CASE: gt_18_user_scale_preserved
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: gt_01's plot with a user-supplied scale_x_continuous carrying
#         limits, breaks and a name. The expansion for the labels edits that
#         scale instead of replacing it, so all three survive: the axis is
#         titled "custom x title", its only breaks are -10, 0 and 10, and the
#         data is clipped to -12..12 by the limits. The labels "x2: 0" and
#         "x2: 4" still fit at the right ends. The case must stay SILENT —
#         ggplot2's "Scale for x is already present" message would mean the
#         scale was replaced.

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
  scale_x_continuous(limits = c(-12, 12), breaks = c(-10, 0, 10),
                     name = "custom x title") +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text() +
  labs(title = "gt_18: A user's scale_x_continuous survives the expansion",
       subtitle = "EXPECT: title 'custom x title', breaks only at -10/0/10, labels fit")
p
