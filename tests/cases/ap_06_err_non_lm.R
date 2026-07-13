# CASE: ap_06_err_non_lm
# TYPE: console
# FUNC: autoplot
# EXPECT: A clear error rejecting the non-lm object. A data.frame does not
#         dispatch to autoplot.lm, so this currently falls through to
#         ggplot2's autoplot.default error — acceptable, but it carries no
#         Applr-flavored hint to fit an lm() first.

source("testing/_setup.R")

not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

try_show(autoplot(not_a_model))
