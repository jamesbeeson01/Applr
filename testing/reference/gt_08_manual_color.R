# gt_08 REFERENCE — skyblue lines, BLACK labels (manual color override).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

lines <- do.call(rbind, lapply(c(0, 4), function(v) {
  s <- ref_slice(model, dat, "x", held = list(x2 = v))
  s$label <- paste0("x2: ", v)
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
            color = "skyblue", linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label),
            color = "black", hjust = 0, vjust = 0.5, nudge_x = nx) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_08 REFERENCE — black labels on skyblue lines",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("testing/reference/gt_08_manual_color.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gt_08_manual_color.png")
