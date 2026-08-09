# sb_15 REFERENCE — the sb_14 model on a 4.5-inch plot. At this width the
# longest interaction terms are wider than what a hanging indent would leave
# behind, so the correct rendering drops the indent and starts every line at
# the left edge: one term per line, nothing pushed off the plot.
source("tests/reference/_ref_helpers.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)
held <- list(Petal.Length = mean(iris$Petal.Length))

s <- do.call(rbind, lapply(levels(iris$Species), function(lev) {
  sub <- iris[iris$Species == lev, ]
  out <- ref_slice(model, sub, "Sepal.Width",
                   held = c(held, list(Species = factor(lev, levels(iris$Species)))))
  out$Species <- factor(lev, levels(iris$Species))
  out
}))

subtitle <- paste(c(
  'Sepal.Length = 1.67 + 0.624*Sepal.Width',
  '+ 0.283*(Species="versicolor")',
  '- 0.646*(Species="virginica")',
  '+ 0.822*Petal.Length',
  '- 0.448*Sepal.Width:(Species="versicolor")',
  '- 0.286*Sepal.Width:(Species="virginica")',
  ref_held_line(held)), collapse = "\n")

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_line(data = s, aes(Sepal.Width, .pred, color = Species), linewidth = 1) +
  labs(title = "sb_15 REFERENCE — narrow plot", subtitle = subtitle)

ggsave("tests/reference/sb_15_narrow_plot_wraps.png", plot = p,
       width = 4.5, height = 4.5)
message("OK: tests/reference/sb_15_narrow_plot_wraps.png")
