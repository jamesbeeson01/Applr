# gs_05_quadratic.R
# EXPECT: Scatter of x vs y (y ~ x + I(x^2)). One curved parabola-shaped line.
#         The curve should open upward and pass through the point cloud.
#         Not a straight line — must show visible curvature.
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
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

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_05_quadratic.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_05_quadratic.png")
