# CASE: ga_01_single_predictor
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Scatter of x vs y with one slice line of slope ~1 from
#         geom_add_slice_2d().

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_add_slice_2d(model)
