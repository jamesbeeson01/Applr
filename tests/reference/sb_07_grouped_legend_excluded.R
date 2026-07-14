# sb_07 REFERENCE — one slice per color group (g pinned per group, spanning
# each group's own x-range), x2 held at its mean; the legend labels g, so the
# subtitle reports only x2 (model = FALSE in the case, so no equation line).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 80
x <- runif(n, -10, 10)
g <- sample(c("A", "B"), n, replace = TRUE)
x2 <- runif(n, 0, 5)
y <- x + ifelse(g == "A", 0, 6) + ifelse(g == "A", 1, -0.5) * x + 1.5 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

m2 <- mean(dat$x2)
lines <- do.call(rbind, lapply(c("A", "B"), function(gv) {
  s <- ref_slice(model, dat[dat$g == gv, ], "x", held = list(g = gv, x2 = m2))
  s$g <- gv
  s
}))

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.6) +
  geom_line(data = lines, aes(x, .pred, color = g), linewidth = 1) +
  labs(title = "sb_07 REFERENCE — legend labels g, only x2 in subtitle",
       subtitle = ref_held_line(list(x2 = m2)))

ggsave("tests/reference/sb_07_grouped_legend_excluded.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/sb_07_grouped_legend_excluded.png")
