# CASE: gt_17_warn_labels_too_wide
# TYPE: console
# SIZE: 3x3
# FUNC: geom_slice_text
# EXPECT: A warning that the labels cannot fit: on a 3x3 in device the panel
#         is about 190pt wide and each label
#         "concentration_in_micrograms: ..." is wider than half of that. The
#         reserve stops at half the panel rather than crowding out the data,
#         so the labels clip and the warning says so, with a hint to widen the
#         plot or shorten the labels via `style`.

source("tests/_setup.R")
set.seed(123)

n <- 30
x <- runif(n, -10, 10)
concentration_in_micrograms <- runif(n, 0, 4)
y <- x + 2 * concentration_in_micrograms + rnorm(n)
dat <- data.frame(x, y, concentration_in_micrograms)

model <- lm(y ~ x + concentration_in_micrograms, data = dat)

try_show(
  ggplot(dat, aes(x, y)) +
    geom_point() +
    geom_slice(model, predict_vars = list(concentration_in_micrograms = c(0.5, 3.5))) +
    geom_slice_text()
)
