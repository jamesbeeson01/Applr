# CASE: sb_18_warn_bad_style
# TYPE: console
# FUNC: geom_slice_subtitle
# EXPECT: The same warning arriving through the `...` passthrough. Nothing in
#         geom_slice_subtitle() inspects `style`; it reaches lm_equation() at
#         plot-add time, warns there, and the subtitle is written with
#         "prettier" so the plot still builds.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width + Species, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point() +
  geom_slice(model)

try_show((p + geom_slice_subtitle(style = "pretty please"))$labels$subtitle)
