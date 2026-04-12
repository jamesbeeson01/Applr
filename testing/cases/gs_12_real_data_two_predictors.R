# gs_12_real_data_two_predictors.R
# EXPECT: mtcars scatter (disp vs mpg). Model is mpg ~ disp + hp.
#         One fitted line with hp held at its mean (~146).
#         Line should slope downward (more displacement → less mpg) and pass
#         through the middle of the point cloud.
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))

model <- lm(mpg ~ disp + hp, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_12: Real data — mpg ~ disp + hp, default held (hp = mean)",
       subtitle = "EXPECT: One downward-sloping line through the point cloud")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_12_real_data_two_predictors.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_12_real_data_two_predictors.png")
