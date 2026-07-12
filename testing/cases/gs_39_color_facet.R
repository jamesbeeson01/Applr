# CASE: gs_39_color_facet
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Color grouping (x2) + faceting (x3) combined, showing
#         6 lines, 3 per facet. Facets (x3) have values 1, 2. 
#         color (x2) has values 0, 2, 4. No console output.

source("testing/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- sample(c(0, 2, 4), n, replace = TRUE)
x3 <- sample(c(0, 1), n, replace = TRUE)
y <- x + 3 * x2 + 3 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

ggplot(dat, aes(x, y, color = factor(x2))) +
  geom_point() +
  geom_slice(model) +
  facet_wrap(~x3)
