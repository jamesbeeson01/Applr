# sb_03 REFERENCE — two slices (x2 = 0, 4) labeled at their right ends like
# gt_01, x3 held at its mean; subtitle reports ONLY x3 (x2 already labeled).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
x3 <- runif(n, -2, 2)
y <- x + 2 * x2 - x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

m3 <- mean(dat$x3)
lines <- do.call(rbind, lapply(c(0, 4), function(v) {
  s <- ref_slice(model, dat, "x", held = list(x2 = v, x3 = m3))
  s$label <- paste0("x2: ", v)
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$label),
                              function(d) d[which.max(d$x), ]))
nx <- 0.012 * diff(range(dat$x))
ex <- 0.025 + 0.013 * max(nchar(ends$label))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines, aes(x, .pred, group = label),
            color = "skyblue", linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label),
            color = "skyblue", hjust = 0, vjust = 0.5, nudge_x = nx) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "sb_03 REFERENCE — x2 labeled on-plot, only x3 in subtitle",
       subtitle = paste0(ref_equation(model), "\n", ref_held_line(list(x3 = m3))))

ggsave("tests/reference/sb_03_text_labeled_excluded.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/sb_03_text_labeled_excluded.png")
