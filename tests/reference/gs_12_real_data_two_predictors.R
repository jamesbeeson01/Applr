# gs_12 REFERENCE — mtcars, mpg ~ disp + hp, hp held at its mean (geom_slice default).
source("tests/reference/_ref_helpers.R")
model <- lm(mpg ~ disp + hp, data = mtcars)

ref <- ref_slice(model, mtcars, "disp", held = list(hp = mean(mtcars$hp)))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(disp, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_12 REFERENCE — mpg ~ disp + hp, hp = mean(hp)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_12_real_data_two_predictors.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_12_real_data_two_predictors.png")
