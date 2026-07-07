# CASE: gf_10_interaction_faceted
# TYPE: visual
# FUNC: geom_fit
# SIZE: 10x4
# EXPECT: Model y ~ x:x_switch with facet_wrap(~x_switch): the correct line
#         per panel (slopes 0, ~1, ~2).
#         KNOWN ISSUE: currently errors "variable lengths differ (found for
#         'x_switch')" — geom_fit does not support faceting without explicit
#         new_data.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

ggplot(data.frame(x, y, x_switch), aes(x, y)) +
  geom_point() +
  geom_fit(model) +
  facet_wrap(~x_switch)
