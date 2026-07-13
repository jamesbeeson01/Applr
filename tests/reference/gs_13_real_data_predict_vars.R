# gs_13 REFERENCE — mtcars, mpg ~ disp + hp, two slices at hp=100 (blue) and hp=250 (red).
source("testing/reference/_ref_helpers.R")
model <- lm(mpg ~ disp + hp, data = mtcars)

ref_lo <- ref_slice(model, mtcars, "disp", held = list(hp = 100))
ref_hi <- ref_slice(model, mtcars, "disp", held = list(hp = 250))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "gray60") +
  geom_line(data = ref_lo, aes(disp, .pred), color = "steelblue", linewidth = 1) +
  geom_line(data = ref_hi, aes(disp, .pred), color = "firebrick", linewidth = 1) +
  labs(title = "gs_13 REFERENCE — two slices at hp=100 (blue) and hp=250 (red)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_13_real_data_predict_vars.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_13_real_data_predict_vars.png")
