# CASE: dw_05_interaction_three_curves
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y ~ x:x_switch. ONE scatter plot with THREE curves drawn
#         (x_switch = 0, 1, 2): slopes 0, ~1, ~2.
#         KNOWN ISSUE: currently errors "'expr' did not evaluate to an object
#         of length 'n'" — the "x:x_switch" coefficient name is pasted into the
#         curve() equation, where ":" parses as the sequence operator.

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
drawit(model, xaxis = "x", x_switch = 0)
drawit(model, xaxis = "x", x_switch = 1)
drawit(model, xaxis = "x", x_switch = 2)
