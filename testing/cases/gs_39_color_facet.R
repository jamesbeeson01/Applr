# CASE: gs_39_color_facet
# TYPE: visual
# FUNC: geom_slice
# EXPECT: BROKEN CASE — needs a redesign before it can assert anything.
#         The body was copied from gs_38 but x2/x3 are CONTINUOUS runif
#         draws, so aes(color = factor(x2)) and facet_wrap(~factor(x3))
#         produce one level per observation: ~60 facets and a 60-entry
#         legend. There is also no reference image. Intended purpose
#         (per the filename): color grouping + faceting combined. To make
#         it meaningful, x2/x3 must be drawn from small discrete sets and
#         a reference must be added; until then, do not snapshot its
#         console output (currently: x3 imputed at its mean).

source("testing/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 4)
x3 <- runif(n, 0, 5)
y <- x + 3 * x2 + 0.7 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

ggplot(dat, aes(x, y, color = factor(x2))) +
  geom_point() +
  facet_wrap(~factor(x3)) +
  geom_slice(model)
