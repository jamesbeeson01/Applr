# CASE: sb_07_grouped_legend_excluded
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: Interaction model y ~ x * g + x2 with aes(color = g): one slice per
#         group, g pinned per group and ALREADY labeled by the color legend,
#         x2 imputed at its mean. The subtitle must exclude g (the legend
#         covers it) and report only x2. model = FALSE here, so the subtitle
#         is the single line "held at: x2 = <mean>".
#         Console message: x2 not specified, held at its mean (~2.578).

source("testing/_setup.R")
set.seed(123)

n <- 80
x <- runif(n, -10, 10)
g <- sample(c("A", "B"), n, replace = TRUE)
x2 <- runif(n, 0, 5)
y <- x + ifelse(g == "A", 0, 6) + ifelse(g == "A", 1, -0.5) * x + 1.5 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.6) +
  geom_slice(model) +
  geom_slice_subtitle(model = FALSE) +
  labs(title = "sb_07: legend labels g, so only x2 in the subtitle")
p
