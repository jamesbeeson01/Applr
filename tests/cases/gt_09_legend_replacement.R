# CASE: gt_09_legend_replacement
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Interaction model y ~ x * g with aes(color = g) and the color legend
#         suppressed. With no predict_vars, geom_slice_text labels each line
#         with its GROUPING variable instead: "g: A" and "g: B" at the right
#         ends, each in its line's color — the labels replace the legend.

source("tests/_setup.R")
set.seed(123)

n <- 80
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B"), n, replace = TRUE))
y <- x * ifelse(g == "A", 0.5, 2) + ifelse(g == "A", 5, -5) + rnorm(n)
dat <- data.frame(x, g, y)
model <- lm(y ~ x * g, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  geom_slice(model) +
  geom_slice_text() +
  guides(color = "none") +
  labs(title = "gt_09: end-of-line labels as a legend replacement",
       subtitle = "EXPECT: no legend; 'g: A' and 'g: B' at line ends in group colors")
p
