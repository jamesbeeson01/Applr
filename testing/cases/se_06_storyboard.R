# CASE: se_06_storyboard
# TYPE: visual
# FUNC: slice_explore
# EXPECT: A static "storyboard" of the hp slider's sweep: mtcars scatter
#         (disp vs mpg) with THREE parallel slice lines taken from the
#         precomputed slider grid — hp at its minimum (52, top line), its
#         mean (146.7, middle line, the slider's starting position), and its
#         maximum (335, bottom line) — with a legend naming the hp values.
#         Must match the reference, which draws the same three slices with
#         plain predict() and no Applr: proves the slider's precomputed
#         curves ARE the model's slices.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
spec <- suppressMessages(Applr:::explore_spec(model, rlang::quo(hp)))

s <- spec$sliders[[1]]
pos <- c(1, s$init + 1, length(s$values))  # slider at min, start (mean), max
cv <- spec$curves[[1]]
lines <- do.call(rbind, lapply(pos, function(i) {
  data.frame(disp = cv$x, mpg = cv$y[[i]], hp = format(signif(s$values[i], 4)))
}))
lines$hp <- factor(lines$hp, levels = unique(lines$hp))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_line(data = lines, aes(color = hp), linewidth = 1) +
  labs(title = "se_06: slider sweep storyboard (hp at min / mean / max)",
       subtitle = "Lines from slice_explore's precomputed slider grid",
       color = "hp")
p
