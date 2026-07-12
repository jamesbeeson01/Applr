# CASE: s2_01_single_predictor
# TYPE: visual
# FUNC: slice_2d
# EXPECT: slice_2d creates its own base plot: scatter of x vs y (steelblue
#         points) with a slice line of slope ~1 through the points.
#         Console message: xaxis not specified, first x variable (x) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

slice_2d(model)
