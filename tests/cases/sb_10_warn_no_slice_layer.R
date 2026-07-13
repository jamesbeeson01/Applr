# CASE: sb_10_warn_no_slice_layer
# TYPE: console
# FUNC: geom_slice_subtitle
# EXPECT: A clear warning that the plot has no geom_slice() layer to describe
#         (there is no model or held values to report), with a hint to add
#         geom_slice() before geom_slice_subtitle(). Mirrors
#         gt_11_warn_no_slice_layer.

source("testing/_setup.R")
set.seed(123)

n <- 30
x <- runif(n, -10, 10)
y <- x + rnorm(n)
dat <- data.frame(x, y)

try_show(
  ggplot(dat, aes(x, y)) +
    geom_point() +
    geom_slice_subtitle()
)
