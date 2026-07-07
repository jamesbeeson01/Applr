# CASE: ga_07_interaction_grouped
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Model y ~ x:x_switch with color = factor(x_switch) in aes(): review
#         whether a single geom_add_slice_2d call draws a line per group or
#         one line at the imputed default (a console message reveals which).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

ggplot(data.frame(x, y), aes(x, y, color = factor(x_switch))) +
  geom_point() +
  geom_add_slice_2d(model)
