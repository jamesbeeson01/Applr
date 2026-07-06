# gs_15 REFERENCE — mtcars, mpg ~ disp + hp + wt + drat, with hp, wt, drat all held.
source("testing/reference/_ref_helpers.R")
model <- lm(mpg ~ disp + hp + wt + drat, data = mtcars)

ref <- ref_slice(model, mtcars, "disp", held = list(hp = 110, wt = 3.0, drat = 3.5))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(disp, .pred), color = "darkorange", linewidth = 1.2) +
  labs(title = "gs_15 REFERENCE — mpg ~ disp + hp + wt + drat (hp=110, wt=3.0, drat=3.5)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_15_many_predictors.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_15_many_predictors.png")
