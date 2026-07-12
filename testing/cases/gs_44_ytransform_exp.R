# CASE: gs_44_ytransform_exp
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x_pos vs y on the ORIGINAL y scale. Model is
#         exp(y) ~ x_pos (y = log(x_pos) + noise), so geom_slice must
#         back-transform via log(fitted): a LOGARITHMIC curve (steep at
#         small x_pos, flattening to the right). Straight line = FAIL.
#         Console message: predictions of exp(y) back-transformed to the
#         y axis.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0.5, 10)  # bounded away from 0 to keep log(x_pos) tame
y <- log(x_pos) + rnorm(n, sd = 0.1)
model <- lm(exp(y) ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_44: Y-transform exp(y) ~ x_pos",
       subtitle = "EXPECT: Logarithmic curve (back-transformed). Straight line = FAIL.")
p
