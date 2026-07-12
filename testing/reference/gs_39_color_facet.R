# gs_39 REFERENCE — six slices: x2 in {0, 2, 4} (color) crossed with
# x3 in {0, 1} (facet). Three colored lines per facet.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 60
x <- runif(n, -10, 10)
x2 <- sample(c(0, 2, 4), n, replace = TRUE)
x3 <- sample(c(0, 1), n, replace = TRUE)
y <- x + 3 * x2 + 3 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

combos <- expand.grid(x2 = c(0, 2, 4), x3 = c(0, 1))
lines <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
  sub <- dat[dat$x3 == combos$x3[i], ]
  line <- ref_slice(model, sub, "x",
                    held = list(x2 = combos$x2[i], x3 = combos$x3[i]))
  line$x2 <- combos$x2[i]
  line$x3 <- combos$x3[i]
  line
}))

p <- ggplot(dat, aes(x, y, color = factor(x2))) +
  geom_point() +
  geom_line(data = lines,
            aes(x, .pred, color = factor(x2), group = interaction(x2, x3)),
            linewidth = 1) +
  facet_wrap(~x3) +
  labs(title = "gs_39 REFERENCE — six slices: x2 in {0,2,4} (color) x x3 in {0,1} (facet)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)",
       color = "x2")

ggsave("testing/reference/gs_39_color_facet.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_39_color_facet.png")
