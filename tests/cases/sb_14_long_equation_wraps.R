# CASE: sb_14_long_equation_wraps
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Three iris slices, one per Species. The model equation is far wider
#         than the plot, so geom_slice_subtitle() breaks it over several
#         lines. Breaks fall BETWEEN terms only — every line after the first
#         starts with a "+" or "-" carrying its own coefficient, and no line
#         ends with a stranded operator. Continuation lines hang under the
#         right-hand side of the equal sign, aligned with the "1.67" on line
#         one (not with "Sepal.Length"). No line runs past the panel's right
#         edge, and the subtitle never overlaps the panel: the plot area
#         shrinks to make room for however many lines the equation needs.
#         The "held at:" line is short and stays on one line of its own.
#         This is the top rung of the ladder: wide enough to spell the factor
#         names out AND keep the indent, so nothing is given up. sb_19,
#         sb_20 and sb_15 are the same model and code at narrower widths,
#         giving up one thing at a time.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_14: Long equation wrapped to the plot width")
p
