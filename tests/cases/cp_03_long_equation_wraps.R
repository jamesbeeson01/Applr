# CASE: cp_03_long_equation_wraps
# TYPE: visual
# FUNC: geom_slice_caption
# EXPECT: The caption twin of sb_14 — the same iris model, wrapped into the
#         caption instead of the subtitle. Two differences follow from what a
#         caption is. It is set in the theme's smaller caption size (8.8pt,
#         not 11pt), so more of the equation fits per line and it needs three
#         lines here where the subtitle needed four. And it is right-aligned,
#         so there is NO hanging indent: lines sit flush against the right
#         edge with a ragged left edge, since aligning to the equal sign only
#         means anything when lines start at a common left edge. Breaks still
#         fall between terms only — every line after the first opens with a
#         "+" or "-" and its own coefficient. Nothing runs past the panel's
#         right edge, and the panel shrinks upward to make room for all four
#         lines rather than being overlapped. The "held at:" line stays whole
#         on the last line.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_caption() +
  labs(title = "cp_03: Long equation in the caption")
p
