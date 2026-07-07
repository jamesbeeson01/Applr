# CASE: s2_06_multiplicative_xaxis_product
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos) with xaxis = "x*x_pos" (the product itself):
#         same as the default plot in s2_04.
#         KNOWN ISSUE: currently errors "xaxis variable 'x*x_pos' not found in
#         the model." — the I() term is stored under a different name.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model, xaxis = "x*x_pos")
