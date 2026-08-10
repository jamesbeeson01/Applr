# CASE: sb_19_brackets_keeps_indent
# TYPE: visual
# SIZE: 5.25x4.5
# FUNC: geom_slice_subtitle
# EXPECT: The second rung of the ladder — shortening the labels in order to
#         KEEP the hanging indent. The same model as sb_14 and sb_15, at a
#         width between theirs. Spelled out, the interaction terms are too
#         wide to sit under a hanging indent, so the spelled-out form could
#         only fit by giving the indent up. Written as [versicolor] and
#         [virginica] they fit with the indent intact, and that is preferred:
#         losing the indent costs the equation its shape on every line, while
#         the briefer labels cost the variable name only on the terms that
#         carry a factor. So expect bracketed labels AND continuation lines
#         hanging under the right-hand side of the equal sign, aligned with
#         the "1.67". Console message: the shortening is announced, showing
#         the two forms of a real term rather than describing them, with a
#         hint naming `style = "prettier"` to override.
#         Compare sb_14 (wide enough for both), sb_20 (indent
#         unaffordable even bracketed, so the names come back) and sb_15
#         (neither affordable).

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_19: Shortened to keep the indent")
p
