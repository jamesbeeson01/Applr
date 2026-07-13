# CASE: gs_01_single_predictor
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x vs y with one straight fitted line through the points.
#         Line should be nearly perfect (y = x, so slope ~1, intercept ~0).
#         No errors or warnings about missing variables.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x  # perfect linear relationship, no noise
model <- lm(y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_01: Single predictor (y ~ x)",
       subtitle = "EXPECT: One straight line, slope=1, intercept=0")
p
