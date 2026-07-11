# CASE: sb_06_format_function
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: The high-control version: format = function(equation, values) takes
#         the ready-made equation string and the named list of unlabeled held
#         values, and returns the whole subtitle. Here it builds ONE line:
#         "Fitted <equation> holding x2 at <mean>". When format is given, it
#         fully replaces the default layout (and prepend/append/model are
#         ignored/unused).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model) +
  geom_slice_subtitle(
    format = function(equation, values) {
      paste0("Fitted ", equation, " holding x2 at ",
             format(signif(values$x2, 4)))
    }
  ) +
  labs(title = "sb_06: custom format function builds the whole subtitle")
p
