# CASE: sb_15_narrow_plot_wraps
# TYPE: visual
# FUNC: geom_slice_subtitle
# SIZE: 4.5x4.5
# EXPECT: The same model as sb_14 on a plot half the width, which is narrower
#         than the widest spelled-out term: `0.286*Sepal.Width:
#         (Species="virginica")` does not fit on a line of its own, and no
#         break can rescue it. So the fallback fires and factor terms are
#         labelled by level alone — [versicolor], [virginica],
#         Sepal.Width:[versicolor] — which does fit. Levels identify their own
#         factor here (Species is the only one), which is what makes the
#         shortening safe. The indent is dropped too: even the shortened
#         interaction terms are wider than what a hanging indent would leave
#         behind, so all lines start at the left edge and none reaches the
#         legend. Breaks still fall between terms only. As in sb_14 the panel
#         shrinks to fit the taller subtitle instead of being overlapped by
#         it. Console message: the shortening is announced, alongside the
#         usual held-value message. This is the bottom rung of the ladder —
#         both the indent and the
#         spelled-out names have been given up, in that order of reluctance.
#         Compare sb_14 (gives up neither), sb_19 (gives up the names to keep
#         the indent) and sb_20 (gives up the indent, so takes the names
#         back).

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_15: Narrow plot")
p
