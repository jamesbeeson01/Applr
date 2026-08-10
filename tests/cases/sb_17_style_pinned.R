# CASE: sb_17_style_pinned
# TYPE: visual
# SIZE: 4.5x4.5
# FUNC: geom_slice_subtitle
# EXPECT: The escape hatch from the sb_15 fallback. Identical to sb_15 in
#         every respect — same model, same 4.5-inch width — except for
#         `style = "prettier"`, which goes through `...` to lm_equation()
#         under lm_equation()'s own argument name, and pins the style
#         instead of letting the wrap choose. So where sb_15 shortened to
#         [versicolor], this keeps (Species="versicolor") and lets the long
#         interaction terms run off the plot. That is the point: a reader who
#         does not want the labels to depend on the size of the device can
#         say so, and gets the same labels at every width. Pinning also
#         silences the "Factor terms were shortened" message, since nothing
#         is being chosen — the console shows only the held-value message.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle(style = "prettier") +
  labs(title = "sb_17: Style pinned")
p
