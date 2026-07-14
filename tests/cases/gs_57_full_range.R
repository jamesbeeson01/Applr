# CASE: gs_57_full_range
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Two colored groups whose points occupy different x ranges (A on the
#         left, B on the right), each with its own slope from the interaction
#         model. With full_range = TRUE both lines span the ENTIRE panel x
#         range (0 to ~10), extending well past their own group's points.
#         No errors or warnings.

source("tests/_setup.R")
set.seed(57)

n <- 40
g <- rep(c("A", "B"), each = n / 2)
x <- c(runif(n / 2, 0, 4), runif(n / 2, 6, 10))  # disjoint x ranges per group
y <- ifelse(g == "A", 2 + 1.5 * x, 12 - 0.8 * x) + rnorm(n, sd = 0.5)
dat <- data.frame(x, y, g = factor(g))
model <- lm(y ~ x * g, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point() +
  geom_slice(model, full_range = TRUE) +
  labs(title = "gs_57: full_range = TRUE",
       subtitle = "EXPECT: Both lines span the whole panel, past their group's points")
p
