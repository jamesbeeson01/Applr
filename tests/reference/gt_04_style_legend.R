# gt_04 REFERENCE — six slices with bare-value labels ("0; 0", ...) at line
# ends plus a corner key "labels: x2; x3" top-right, all skyblue.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 4)
x3 <- runif(n, 0, 2)
y <- x + 4 * x2 + 3 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

combos <- expand.grid(x2 = c(0, 2, 4), x3 = c(0, 1))
lines <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
  s <- ref_slice(model, dat, "x",
                 held = list(x2 = combos$x2[i], x3 = combos$x3[i]))
  s$label <- paste0(combos$x2[i], "; ", combos$x3[i])
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$label),
                              function(d) d[which.max(d$x), ]))

# Constant gap past the line end; x-expansion sized by the widest label,
# plus y-headroom so the corner key clears the topmost line's label.
nx <- 0.012 * diff(range(dat$x))
ex <- ref_text_expand(ends$label)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines, aes(x, .pred, group = label),
            color = "skyblue", linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label),
            color = "skyblue", hjust = 0, vjust = 0.5, nudge_x = nx) +
  annotate("text", x = Inf, y = Inf, label = "labels: x2; x3",
           color = "skyblue", hjust = 1.1, vjust = 1.5) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.1))) +
  labs(title = "gt_04 REFERENCE — value labels + corner key 'labels: x2; x3'",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("tests/reference/gt_04_style_legend.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gt_04_style_legend.png")
