# CASE: gs_06_interaction_manual_slices
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x vs y (y ~ x:x_switch) with three lines — one per x_switch level.
#         x_switch=0 -> slope=0 (flat line at y=0)
#         x_switch=1 -> slope~1
#         x_switch=2 -> slope~2
#         Three distinct lines with different slopes radiating from origin.
#         No errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch + rnorm(n)
model <- lm(y ~ x:x_switch)

colors <- c("0" = "steelblue", "1" = "darkgreen", "2" = "purple")

p <- ggplot(data.frame(x, y, x_switch = factor(x_switch)), aes(x, y, color = x_switch)) +
  geom_point() +
  scale_color_manual(values = colors) +
  geom_slice(model, predict_vars = list(x_switch = 0), color = "steelblue", linewidth = 1) +
  geom_slice(model, predict_vars = list(x_switch = 1), color = "darkgreen", linewidth = 1) +
  geom_slice(model, predict_vars = list(x_switch = 2), color = "purple", linewidth = 1) +
  labs(title = "gs_06: Interaction model, three manual slices",
       subtitle = "EXPECT: Three lines with slopes 0, ~1, ~2 for x_switch = 0, 1, 2")
p
