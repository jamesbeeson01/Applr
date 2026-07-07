# CASE: ga_17_err_non_lm
# TYPE: console
# FUNC: geom_add_slice_2d
# EXPECT: A clear, student-readable error rejecting the non-lm object
#         ("Model must be in lm() format").

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_add_slice_2d(not_a_model))
