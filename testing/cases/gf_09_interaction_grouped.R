# CASE: gf_09_interaction_grouped
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model y ~ x:x_switch with color = factor(x_switch) in aes(): one
#         geom_fit call drawing a line per group.
#         KNOWN ISSUE: currently errors "variable lengths differ (found for
#         'x_switch')" — geom_fit does not support aesthetic grouping without
#         explicit new_data.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

ggplot(data.frame(x, y), aes(x, y, color = factor(x_switch))) +
  geom_point() +
  geom_fit(model)
