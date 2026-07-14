# CASE: s2_15_err_non_lm
# TYPE: console
# FUNC: slice_2d
# EXPECT: A clear, student-readable error rejecting the non-lm object
#         ('`model` must be a model fitted by `lm()`; received a "..."',
#         with a refit hint), not an obscure internal one.

source("tests/_setup.R")

not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

try_show(slice_2d(not_a_model))
