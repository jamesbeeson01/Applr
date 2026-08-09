# cp_03 REFERENCE — the sb_14 model reported in the caption instead of the
# subtitle. The break points are chosen here by hand: between terms, each line
# as full as the caption's smaller 8.8pt type allows. No hanging indent — the
# caption is right-aligned, so the lines are flush right and the left edge is
# ragged.
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

caption <- paste(c(
  'Sepal.Length = 1.67 + 0.624*Sepal.Width + 0.283*(Species="versicolor")',
  '- 0.646*(Species="virginica") + 0.822*Petal.Length - 0.448*Sepal.Width:(Species="versicolor")',
  '- 0.286*Sepal.Width:(Species="virginica")',
  ref_held_line(held)), collapse = "\n")

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_line(data = s, aes(Sepal.Width, .pred, color = Species), linewidth = 1) +
  labs(title = "cp_03 REFERENCE — long equation in the caption",
       caption = caption)

ggsave("tests/reference/cp_03_long_equation_wraps.png", plot = p,
       width = 7, height = 5)
message("OK: tests/reference/cp_03_long_equation_wraps.png")
