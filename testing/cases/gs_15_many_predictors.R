# gs_15_many_predictors.R
# EXPECT: mtcars scatter (disp vs mpg). Model has 4 predictors: disp + hp + wt + drat.
#         predict_vars holds hp, wt, and drat at specific values.
#         One downward-sloping line representing the slice.
#         Tests that geom_slice can handle many held variables simultaneously.
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))

model <- lm(mpg ~ disp + hp + wt + drat, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model,
             predict_vars = list(hp = 110, wt = 3.0, drat = 3.5),
             color = "darkorange", linewidth = 1.2) +
  labs(title = "gs_15: Many predictors — mpg ~ disp + hp + wt + drat",
       subtitle = "EXPECT: One line, hp=110, wt=3.0, drat=3.5 held. No errors.")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_15_many_predictors.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_15_many_predictors.png")
