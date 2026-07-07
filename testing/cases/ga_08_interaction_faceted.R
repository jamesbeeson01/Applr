# CASE: ga_08_interaction_faceted
# TYPE: visual
# FUNC: geom_add_slice_2d
# SIZE: 10x4
# EXPECT: Model y ~ x:x_switch with facet_wrap(~x_switch): review whether
#         each panel gets its own correctly-sliced line or the same line is
#         repeated in every panel.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

ggplot(data.frame(x, y, x_switch), aes(x, y)) +
  geom_point() +
  geom_add_slice_2d(model) +
  facet_wrap(~x_switch)
