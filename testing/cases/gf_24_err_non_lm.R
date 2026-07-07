# CASE: gf_24_err_non_lm
# TYPE: console
# FUNC: geom_fit
# EXPECT: A clear, student-readable error rejecting the non-lm object.
#         Currently fails with min/max warnings and "'from' must be a finite
#         number" — should be a friendly model-type check instead.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_fit(not_a_model))
