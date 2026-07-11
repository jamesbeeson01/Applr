# CASE: gt_06_offset_hjust_vjust
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Two parallel skyblue slices (x2 held at 0 and 4). Setting hjust
#         manually DISABLES the automatic point-offset, and expand = FALSE
#         turns off the automatic x-range widening, so each "x2: v" label
#         sits INSIDE the panel, tucked above the right end of its line
#         (hjust = 1: right-aligned to the line end; vjust = -0.8: lifted
#         off the line).

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
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text(model, predict_vars = list(x2 = c(0, 4)),
                  hjust = 1, vjust = -0.8, expand = FALSE) +
  labs(title = "gt_06: manual hjust/vjust offsets",
       subtitle = "EXPECT: labels above and inside the right line ends")
p
