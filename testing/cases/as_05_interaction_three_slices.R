# CASE: as_05_interaction_three_slices
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ x:x_switch. ONE scatter plot with THREE slice lines added
#         (x_switch = 0, 1, 2): slopes 0, ~1, ~2 radiating from the origin.
#         Console: the xaxis-not-specified message prints THREE times, once
#         per add_slice_2d() call.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

plot(x, y, main = "Interaction: y ~ x:x_switch",
     xlab = "x", ylab = "y", pch = 19,
     col = c("steelblue", "darkgreen", "purple")[x_switch + 1])
add_slice_2d(model, x_switch = 0)
add_slice_2d(model, x_switch = 1)
add_slice_2d(model, x_switch = 2)
