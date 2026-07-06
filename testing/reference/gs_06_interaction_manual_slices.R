# gs_06 REFERENCE — interaction (y ~ x:x_switch), three manual slices over the
# full x range (single, ungrouped geom_slice calls each see all the data).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch + rnorm(n)
model <- lm(y ~ x:x_switch)
dat <- data.frame(x, y)

ref0 <- ref_slice(model, dat, "x", held = list(x_switch = 0))
ref1 <- ref_slice(model, dat, "x", held = list(x_switch = 1))
ref2 <- ref_slice(model, dat, "x", held = list(x_switch = 2))

colors <- c("0" = "steelblue", "1" = "darkgreen", "2" = "purple")

p <- ggplot(data.frame(x, y, x_switch = factor(x_switch)), aes(x, y, color = x_switch)) +
  geom_point() +
  scale_color_manual(values = colors) +
  geom_line(data = ref0, aes(x, .pred), color = "steelblue", linewidth = 1) +
  geom_line(data = ref1, aes(x, .pred), color = "darkgreen", linewidth = 1) +
  geom_line(data = ref2, aes(x, .pred), color = "purple", linewidth = 1) +
  labs(title = "gs_06 REFERENCE — interaction, three slices (x_switch = 0, 1, 2)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_06_interaction_manual_slices.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_06_interaction_manual_slices.png")
