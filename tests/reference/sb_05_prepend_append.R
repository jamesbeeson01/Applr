# sb_05 REFERENCE — default two-line subtitle wrapped in prepend/append text:
# "Model: <equation>\nheld at: x2 = <mean> (mean-imputed)".
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

held <- list(x2 = mean(dat$x2))
s <- ref_slice(model, dat, "x", held = held)
subtitle <- paste0("Model: ", ref_equation(model), "\n",
                   ref_held_line(held), " (mean-imputed)")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = s, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_05 REFERENCE — prepend/append around the default subtitle",
       subtitle = subtitle)

ggsave("testing/reference/sb_05_prepend_append.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/sb_05_prepend_append.png")
