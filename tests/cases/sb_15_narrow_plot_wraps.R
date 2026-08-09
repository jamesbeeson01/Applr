# CASE: sb_15_narrow_plot_wraps
# TYPE: visual
# FUNC: geom_slice_subtitle
# SIZE: 4.5x4.5
# EXPECT: The same model as sb_14 on a plot half the width. Every term now
#         needs its own line. The longest interaction terms are wider than
#         what a hanging indent would leave behind, so the indent is dropped
#         rather than pushing those terms off the plot — all lines start at
#         the left edge and none reaches the legend. As in sb_14 the panel
#         shrinks to fit the taller subtitle instead of being overlapped by
#         it. Compare with sb_14: same model, same code, different width, and
#         the wrap follows the width.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_15: Narrow plot")
p
