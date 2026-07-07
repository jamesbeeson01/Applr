# CASE: s2_05_multiplicative_xaxis_xpos
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos) with xaxis = "x_pos": scatter of x_pos vs y
#         with a slice line (x held at some value shown in the caption).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model, xaxis = "x_pos")
