# gt_10 REFERENCE — one model as two manually-colored slices (x2 = 0 blue,
# x2 = 1 red), each labeled at its right end in its own line's color.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 2)
y <- x + 6 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

lines <- do.call(rbind, lapply(c(0, 1), function(v) {
  s <- ref_slice(model, dat, "x", held = list(x2 = v))
  s$label <- paste0("x2: ", v)
  s$col <- if (v == 0) "blue" else "red"
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$label),
                              function(d) d[which.max(d$x), ]))

# Constant gap past the line end; x-expansion sized by the longest label.
nx <- 0.012 * diff(range(dat$x))
ex <- 0.025 + 0.013 * max(nchar(ends$label))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines, aes(x, .pred, group = label),
            color = lines$col, linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label),
            color = ends$col, hjust = 0, vjust = 0.5, nudge_x = nx) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_10 REFERENCE — blue 'x2: 0' and red 'x2: 1' labels",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("testing/reference/gt_10_multiple_slice_layers.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gt_10_multiple_slice_layers.png")
