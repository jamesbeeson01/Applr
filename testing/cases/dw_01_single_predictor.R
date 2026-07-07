# CASE: dw_01_single_predictor
# TYPE: visual
# FUNC: drawit
# EXPECT: Base scatter of x vs y with a straight curve of slope ~1 drawn by
#         drawit().

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

plot(x, y, main = "Single Predictor: y ~ x",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x")
