# CASE: gt_07_color_grouped
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Interaction model y ~ x * g + x2 with aes(color = g): two color
#         groups (g = "A", "B") x two x2 values {0, 3} = four lines, two per
#         color. Each line's right end is labeled "x2: 0" or "x2: 3", and each
#         label INHERITS ITS LINE'S COLOR — the two labels on g = "A" lines
#         match A's color, the two on g = "B" lines match B's color.

source("testing/_setup.R")
set.seed(123)

n <- 80
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B"), n, replace = TRUE))
x2 <- runif(n, 0, 4)
y <- x * ifelse(g == "A", 1, 2) + ifelse(g == "A", 0, 8) + 3 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  geom_slice(model, predict_vars = list(x2 = c(0, 3))) +
  geom_slice_text() +
  labs(title = "gt_07: labels inherit line color under aes(color = g)",
       subtitle = "EXPECT: four lines, 'x2: 0'/'x2: 3' labels in each group's color")
p
