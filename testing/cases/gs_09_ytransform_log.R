# gs_09_ytransform_log.R
# EXPECT: Scatter of x_pos vs y on the ORIGINAL (untransformed) y scale.
#         Model is log(y) ~ x_pos, so y = exp(x_pos) approximately.
#         geom_slice should back-transform: the fitted line must be exponential-shaped
#         (curves upward), NOT a straight line.
#         If the line is straight, back-transformation failed.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos) * exp(rnorm(n, sd = 0.2))  # y = exp(x_pos + noise)
model <- lm(log(y) ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_09: Y-transform log(y) ~ x_pos",
       subtitle = "EXPECT: Exponential curve (back-transformed). Straight line = FAIL.")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_09_ytransform_log.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_09_ytransform_log.png")
