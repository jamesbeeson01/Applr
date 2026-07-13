# CASE: gs_07_interaction_grouped
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Same interaction model as gs_06, but using a single geom_slice() call
#         with color = factor(x_switch) in aes(). geom_slice should auto-detect
#         groups and draw three colored lines (one per x_switch value).
#         Result should visually match gs_06.
#         No errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch + rnorm(n)
model <- lm(y ~ x:x_switch)

p <- ggplot(data.frame(x, y, x_switch = factor(x_switch)),
            aes(x, y, color = factor(x_switch))) +
  geom_point() +
  geom_slice(model) +
  labs(title = "gs_07: Interaction model, auto-grouped via color aesthetic",
       subtitle = "EXPECT: Three colored lines auto-drawn from single geom_slice() call")
p
