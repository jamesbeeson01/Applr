# gt_13 REFERENCE — gt_01's layout on an x-axis spanning 0..50000: two
# parallel slices (x2 = 0, 4), labeled "x2: 0" / "x2: 4" at their right ends
# with the same small visual gap as gt_01 (the nudge scales with the axis
# range, emulating a constant point offset).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 0, 50000)
x2 <- runif(n, 0, 5)
y <- 0.0004 * x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

lines <- do.call(rbind, lapply(c(0, 4), function(v) {
  s <- ref_slice(model, dat, "x", held = list(x2 = v))
  s$label <- paste0("x2: ", v)
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$label),
                              function(d) d[which.max(d$x), ]))

# Constant *visual* gap: the nudge is proportional to the axis range, so it
# stays ≈ 5 pt at 7x5 in no matter the data units.
nx <- 0.012 * diff(range(dat$x))
ex <- ref_text_expand(ends$label)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines, aes(x, .pred, group = label),
            color = "skyblue", linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label),
            color = "skyblue", hjust = 0, vjust = 0.5, nudge_x = nx) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_13 REFERENCE — same pt gap on a 0..50000 x-axis",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("tests/reference/gt_13_offset_scaled_axis.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gt_13_offset_scaled_axis.png")
