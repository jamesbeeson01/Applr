# sb_06 REFERENCE — a custom format function replaces the whole subtitle with
# one line: "Fitted <equation> holding x2 at <mean>".
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

m2 <- mean(dat$x2)
s <- ref_slice(model, dat, "x", held = list(x2 = m2))
subtitle <- paste0("Fitted ", ref_equation(model), " holding x2 at ",
                   format(signif(m2, 4)))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = s, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_06 REFERENCE — custom one-line format function",
       subtitle = subtitle)

ggsave("testing/reference/sb_06_format_function.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/sb_06_format_function.png")
