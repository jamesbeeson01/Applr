# CASE: sb_04_model_off
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Same slice as sb_01 (x2 imputed at its mean), but called with
#         model = FALSE: the equation line is dropped, so the subtitle is the
#         single line "held at: x2 = <mean>".

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
  geom_slice_subtitle(model = FALSE) +
  labs(title = "sb_04: model = FALSE — held-values line only")
p
