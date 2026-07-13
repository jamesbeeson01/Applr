# gs_08 REFERENCE — interaction (y ~ x:x_switch), facet_wrap(~x_switch). One line
# per panel: x_switch held at the panel value, x over that panel's data range.
source("tests/reference/_ref_helpers.R")
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

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  facet_wrap(~x_switch) +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_08 REFERENCE — interaction, facet_wrap(~x_switch)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_08_interaction_faceted.png", plot = p, width = 10, height = 4)
message("OK: tests/reference/gs_08_interaction_faceted.png")
