# CASE: gs_45_ytransform_square
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x_pos vs y on the ORIGINAL y scale. Model is
#         y^2 ~ x_pos (y = sqrt(x_pos) + noise), so geom_slice must
#         back-transform via sqrt(fitted): a SQUARE-ROOT curve (steep at
#         small x_pos, flattening to the right). Straight line = FAIL.
#         Console message: predictions of y^2 back-transformed to the y axis.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0.5, 10)  # bounded away from 0 so fitted y^2 stays positive
y <- sqrt(x_pos) + rnorm(n, sd = 0.05)
model <- lm(y^2 ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_45: Y-transform y^2 ~ x_pos",
       subtitle = "EXPECT: Square-root curve (back-transformed). Straight line = FAIL.")
p
