# gs_03_additive_predict_vars.R
# EXPECT: Same scatter as gs_02 (y ~ x + x_pos), but line uses x_pos = 0.007
#         (near the bottom of x_pos range). Line should be lower than in gs_02
#         because x_pos=0.007 contributes much less to y than mean(x_pos)~=5.
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
model <- lm(y ~ x + x_pos)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model, predict_vars = list(x_pos = 0.007)) +
  labs(title = "gs_03: Additive model, predict_vars = list(x_pos = 0.007)",
       subtitle = "EXPECT: One line near the bottom of the point cloud (x_pos very low)")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_03_additive_predict_vars.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_03_additive_predict_vars.png")
