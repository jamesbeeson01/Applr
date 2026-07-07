# CASE: ga_06_interaction_manual
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Model y ~ x:x_switch. ONE plot with three geom_add_slice_2d layers
#         (x_switch = 0, 1, 2): three lines with slopes 0, ~1, ~2.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

ggplot(data.frame(x, y), aes(x, y, group = x_switch)) +
  geom_point() +
  geom_add_slice_2d(model, x_switch = 0) +
  geom_add_slice_2d(model, x_switch = 1) +
  geom_add_slice_2d(model, x_switch = 2)
