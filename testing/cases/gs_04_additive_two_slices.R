# gs_04_additive_two_slices.R
# EXPECT: Two parallel straight lines on the same scatter plot (y ~ x + x_pos).
#         Blue line = x_pos held at 1 (lower line).
#         Red line  = x_pos held at 9 (upper line).
#         The two lines should be clearly separated (intercept difference ~8),
#         same slope, no crossing.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
model <- lm(y ~ x + x_pos)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x_pos = 1), color = "steelblue", linewidth = 1) +
  geom_slice(model, predict_vars = list(x_pos = 9), color = "firebrick", linewidth = 1) +
  labs(title = "gs_04: Two slices at x_pos=1 (blue) and x_pos=9 (red)",
       subtitle = "EXPECT: Two parallel lines, red higher than blue, same slope")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_04_additive_two_slices.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_04_additive_two_slices.png")
