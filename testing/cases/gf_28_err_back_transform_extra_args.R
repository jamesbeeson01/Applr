# CASE: gf_28_err_back_transform_extra_args
# TYPE: console
# FUNC: geom_fit
# EXPECT: A back_transform function of 2+ arguments should produce a CLEAR
#         error or warning. Currently dies with "cannot coerce type 'closure'
#         to vector of type 'character'" — unhelpful for students.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

try_show(ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
           geom_point() +
           geom_fit(model, back_transform = function(x, y, z, w) exp(x)))
