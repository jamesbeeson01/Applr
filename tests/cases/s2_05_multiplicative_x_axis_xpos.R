# CASE: s2_05_multiplicative_x_axis_xpos
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos) with x_axis = "x_pos": scatter of x_pos vs y
#         with a slice line (x held at some value shown in the caption).
#         Console message: x not specified, held at its mean (~0.4).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model, x_axis = "x_pos")
