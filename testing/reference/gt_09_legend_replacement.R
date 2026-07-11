# gt_09 REFERENCE — no predict_vars: labels come from the grouping aesthetic
# ("g: A", "g: B") in each group's color; the color legend is suppressed.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 80
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B"), n, replace = TRUE))
y <- x * ifelse(g == "A", 0.5, 2) + ifelse(g == "A", 5, -5) + rnorm(n)
dat <- data.frame(x, g, y)
model <- lm(y ~ x * g, data = dat)

lines <- do.call(rbind, lapply(levels(dat$g), function(gi) {
  s <- ref_slice(model, dat[dat$g == gi, ], "x", held = list(g = gi))
  s$g <- gi
  s$label <- paste0("g: ", gi)
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$g),
                              function(d) d[which.max(d$x), ]))

# Constant gap past the line end; x-expansion sized by the longest label.
nx <- 0.012 * diff(range(dat$x))
ex <- 0.025 + 0.013 * max(nchar(ends$label))

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  geom_line(data = lines, aes(x, .pred, color = g, group = g), linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label, color = g),
            hjust = 0, vjust = 0.5, nudge_x = nx, show.legend = FALSE) +
  guides(color = "none") +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_09 REFERENCE — 'g: A' / 'g: B' labels replace the legend",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("testing/reference/gt_09_legend_replacement.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gt_09_legend_replacement.png")
