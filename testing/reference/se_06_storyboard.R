# se_06 REFERENCE — the same three hp slices via plain predict(), no Applr.
# The slice_explore slider grid spans hp's observed range with the exact mean
# as its starting value, so the storyboard's min / start / max positions are
# reproducible here as min(hp) / mean(hp) / max(hp).
library(ggplot2)

model <- lm(mpg ~ disp + hp, data = mtcars)

hp_values <- c(min(mtcars$hp), mean(mtcars$hp), max(mtcars$hp))
disp_grid <- seq(min(mtcars$disp), max(mtcars$disp), length.out = 100)
lines <- do.call(rbind, lapply(hp_values, function(h) {
  data.frame(disp = disp_grid,
             mpg = predict(model, newdata = data.frame(disp = disp_grid, hp = h)),
             hp = format(signif(h, 4)))
}))
lines$hp <- factor(lines$hp, levels = unique(lines$hp))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_line(data = lines, aes(color = hp), linewidth = 1) +
  labs(title = "se_06 REFERENCE — hp slices at min / mean / max via predict()",
       subtitle = "Ground truth (no Applr): what the slider positions must show",
       color = "hp")

ggsave("testing/reference/se_06_storyboard.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/se_06_storyboard.png")
