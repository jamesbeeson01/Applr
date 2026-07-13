# gs_57 REFERENCE — full_range = TRUE. Ground truth, no geom_slice/geom_smooth.
# Each group's line spans the FULL panel x range (all data), not its own range.
source("tests/reference/_ref_helpers.R")
set.seed(57)

n <- 40
g <- rep(c("A", "B"), each = n / 2)
x <- c(runif(n / 2, 0, 4), runif(n / 2, 6, 10))
y <- ifelse(g == "A", 2 + 1.5 * x, 12 - 0.8 * x) + rnorm(n, sd = 0.5)
dat <- data.frame(x, y, g = factor(g))
model <- lm(y ~ x * g, data = dat)

# Full panel range for both groups: pass the whole dataset's x range,
# pin g per line.
refs <- do.call(rbind, lapply(levels(dat$g), function(lev) {
  ref <- ref_slice(model, dat, "x", held = list(g = lev))
  ref$g <- factor(lev, levels = levels(dat$g))
  ref
}))

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point() +
  geom_line(data = refs, aes(x, .pred, color = g), linewidth = 1) +
  labs(title = "gs_57 REFERENCE — full_range = TRUE",
       subtitle = "Ground truth via predict(): both lines span the whole panel x range")

ggsave("tests/reference/gs_57_full_range.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_57_full_range.png")
