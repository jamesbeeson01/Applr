# CASE: sb_20_indent_lost_names_return
# TYPE: visual
# SIZE: 4.75x4.5
# FUNC: geom_slice_subtitle
# EXPECT: The third rung of the ladder, and the one that looks like a step
#         BACKWARDS. Quarter of an inch narrower than sb_19, which is enough
#         that even the bracketed equation can no longer afford the hanging
#         indent. Once the indent is gone there is nothing left to buy with
#         the shorter labels — the spelled-out equation fits flush just as
#         well — so the factor names come back: (Species="versicolor") again,
#         with every line flush to the left edge. Shortening is only ever
#         spent on something it wins, and here it wins nothing. Read sb_19 ->
#         sb_20 together: the labels get LONGER as the plot gets narrower,
#         because what changed is that the indent was given up.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)

p <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color = Species)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_20: Indent lost, names back")
p
