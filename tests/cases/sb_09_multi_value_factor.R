# CASE: sb_09_multi_value_factor
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Model y ~ x + x2 + g (g a factor) with predict_vars =
#         list(x2 = c(0, 4)) and NO geom_slice_text: two unlabeled parallel
#         lines plus g imputed at its most common level. The subtitle's values
#         line lists BOTH, multi-value x2 joined with commas and the factor
#         quoted: "held at: x2 = 0, 4; g = \"A\"" (after the equation line).
#         Console message: g not specified, most common level "A" used.

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
g <- factor(sample(c("A", "A", "B"), n, replace = TRUE))
y <- x + 2 * x2 + ifelse(g == "A", 0, 4) + rnorm(n)
dat <- data.frame(x, x2, g, y)
model <- lm(y ~ x + x2 + g, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_subtitle() +
  labs(title = "sb_09: multi-value x2 and imputed factor g in the subtitle")
p
