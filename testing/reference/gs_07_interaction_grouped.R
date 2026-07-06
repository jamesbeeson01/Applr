# gs_07 REFERENCE — interaction (y ~ x:x_switch), auto-grouped by color. Each line
# spans only its group's x range (the decisions.Rmd group-range rule).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch + rnorm(n)
model <- lm(y ~ x:x_switch)
dat <- data.frame(x, y, x_switch)

ref <- do.call(rbind, lapply(sort(unique(x_switch)), function(v) {
  d <- ref_slice(model, subset(dat, x_switch == v), "x", held = list(x_switch = v))
  d$x_switch <- v
  d
}))

p <- ggplot(data.frame(x, y, x_switch = factor(x_switch)),
            aes(x, y, color = factor(x_switch))) +
  geom_point() +
  geom_line(data = ref, aes(x, .pred, color = factor(x_switch)), linewidth = 1) +
  labs(title = "gs_07 REFERENCE — interaction, grouped by color (per-group x range)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_07_interaction_grouped.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_07_interaction_grouped.png")
