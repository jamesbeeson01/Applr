# CASE: gt_14_narrow_panel_labels_fit
# TYPE: visual
# SIZE: 5x5
# FUNC: geom_slice_text
# EXPECT: Same shape as gt_07 (y ~ x * g + x2 with color = g: four lines, two
#         per group) but on a NARROW 5x5 in device whose panel is squeezed
#         further by the color legend, and with the longest label the default
#         style can produce here, "x2: 0.25". Every label must sit COMPLETELY
#         inside the panel, with a visible gap between the label's right edge
#         and the panel border — none of the four may be cut off. The room
#         reserved has to come from the labels' drawn width in points, not
#         from a fixed share of the x-range, which is what used to clip
#         "x2: 0.25" whenever the panel came out narrow.

source("tests/_setup.R")
set.seed(123)

n <- 80
x <- runif(n, -10, 10)
g <- sample(c("A", "B"), n, replace = TRUE)
x2 <- runif(n, 0, 5)
y <- x + ifelse(g == "A", 0, 6) + ifelse(g == "A", 1, -0.5) * x + 1.5 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point() +
  geom_slice(model, predict_vars = list(x2 = c(0.25, 4.5))) +
  geom_slice_text() +
  labs(title = "gt_14: labels fit a narrow panel",
       subtitle = "EXPECT: all four 'x2: ...' labels inside the panel")
p
