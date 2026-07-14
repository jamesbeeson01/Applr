# CASE: gs_05_quadratic
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x vs y (y ~ x + I(x^2)). One curved parabola-shaped line.
#         The curve should open upward and pass through the point cloud.
#         Not a straight line — must show visible curvature.
#         No errors.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2 + rnorm(n, sd = 3)
model <- lm(y ~ x + I(x^2))

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_05: Quadratic model (y ~ x + I(x^2))",
       subtitle = "EXPECT: Upward-opening parabola through points")
p
