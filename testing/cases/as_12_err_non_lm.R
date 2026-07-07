# CASE: as_12_err_non_lm
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: A clear, student-readable error rejecting the non-lm object
#         ("Model must be in lm() format").

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

plot(x, y, main = "scaffold plot")
try_show(add_slice_2d(not_a_model))
