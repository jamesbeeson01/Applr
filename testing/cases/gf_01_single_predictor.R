# CASE: gf_01_single_predictor
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Scatter of x vs y with a fitted line of slope ~1 plus a (very
#         narrow) confidence ribbon from geom_fit().

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model)
