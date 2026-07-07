# gs_16 REFERENCE — mtcars, mpg ~ factor(cyl) + disp, cyl held at its first level ("4").
source("testing/reference/_ref_helpers.R")
mtcars2 <- mtcars
mtcars2$cyl <- factor(mtcars2$cyl)
model <- lm(mpg ~ cyl + disp, data = mtcars2)

most_common_level <- names(which.max(table(mtcars2$cyl)))
ref <- ref_slice(model, mtcars2, "disp",
                 held = list(cyl = factor(most_common_level, levels = levels(mtcars2$cyl))))

p <- ggplot(mtcars2, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(disp, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_16 REFERENCE — mpg ~ factor(cyl) + disp, cyl = 4 (first level)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_16_factor_predictor.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_16_factor_predictor.png")
