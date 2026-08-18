# CASE: gt_15_band_edges_labeled
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: band = TRUE with no predict_vars (the gs_52 plot, plus labels). The
#         only non-axis predictor is x_pos, so the band spans its imputed
#         min/max range. Labels go on the band's two EDGES, not the band as a
#         whole: "x_pos: <min>" lower, "x_pos: <max>" upper — x_pos's
#         coefficient is positive (gt_16 covers the flipped case).
#         Exactly ONE console message, geom_slice()'s imputed band range:
#         geom_slice_text() resolves the same band silently.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, band = TRUE) +
  geom_slice_text() +
  labs(title = "gt_15: Band edges labeled, not the band as a whole",
       subtitle = "EXPECT: 'x_pos: ~0' on the lower edge, 'x_pos: ~10' on the upper")
p
