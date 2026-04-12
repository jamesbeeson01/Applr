# gs_01_single_predictor.R
# EXPECT: Scatter plot of x vs y with one straight fitted line through the points.
#         Line should be nearly perfect (y = x, so slope ~1, intercept ~0).
#         No errors or warnings about missing variables.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x  # perfect linear relationship, no noise
model <- lm(y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_01: Single predictor (y ~ x)", subtitle = "EXPECT: One straight line, slope=1, intercept=0")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_01_single_predictor.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_01_single_predictor.png")
