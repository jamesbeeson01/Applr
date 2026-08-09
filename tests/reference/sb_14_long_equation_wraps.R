# sb_14 REFERENCE — three iris slices (one per Species, Petal.Length held at
# its mean) with the long model equation wrapped over four lines. The break
# points are chosen here by hand — between terms, each line as full as it can
# be at 7 inches — and the continuation lines are indented to sit under the
# right-hand side of the equal sign.
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

subtitle <- paste0(
  ref_wrapped_equation(
    c('Sepal.Length = 1.67 + 0.624*Sepal.Width + 0.283*(Species="versicolor")',
      '- 0.646*(Species="virginica") + 0.822*Petal.Length',
      '- 0.448*Sepal.Width:(Species="versicolor")',
      '- 0.286*Sepal.Width:(Species="virginica")'),
    prefix = "Sepal.Length = "),
  "\n", ref_held_line(held))

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_line(data = s, aes(Sepal.Width, .pred, color = Species), linewidth = 1) +
  labs(title = "sb_14 REFERENCE — long equation wrapped to the plot width",
       subtitle = subtitle)

ggsave("tests/reference/sb_14_long_equation_wraps.png", plot = p,
       width = 7, height = 5)
message("OK: tests/reference/sb_14_long_equation_wraps.png")
