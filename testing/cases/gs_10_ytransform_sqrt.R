# gs_10_ytransform_sqrt.R
# EXPECT: Scatter of x_pos vs y on the ORIGINAL y scale (y = x_pos^2 approximately).
#         Model is sqrt(y) ~ x_pos, so geom_slice must back-transform via squaring.
#         The fitted line should be parabola-shaped (curves upward).
#         A straight line on this plot means back-transformation failed.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2 + rnorm(n, sd = 2)
y <- pmax(y, 0)  # keep y non-negative for sqrt(y) to be valid
model <- lm(sqrt(y) ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_10: Y-transform sqrt(y) ~ x_pos",
       subtitle = "EXPECT: Parabola-shaped curve (back-transformed). Straight line = FAIL.")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_10_ytransform_sqrt.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_10_ytransform_sqrt.png")
