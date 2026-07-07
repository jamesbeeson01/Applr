# CASE: gs_17_all_features
# TYPE: visual
# FUNC: geom_slice
# SIZE: 10x4
# EXPECT: 3 panels (F1, F2, F3), each with TWO dashed lines of width 1.2 colored
#         by g: the G2 line steeper (slope ~3) than the G1 line (slope ~1).
#         Panel intercepts step up F1 < F2 < F3 (~0, ~10, ~20). Held vars z/w/s
#         are imputed (3 console messages) and do not appear on the plot.
#         If every line within a panel has the SAME slope, the grouping variable
#         g was wrongly imputed instead of taken from the color group.
#
# The full-feature integration test — every geom_slice capability in one plot.
#   Model: y ~ x*g + f + z + w + s   (synthetic, fully balanced so every f x g cell is populated)
#     - x : numeric x-axis
#     - g : color grouping (2 levels, INTERACTS with x -> different slopes per group)
#     - f : faceting variable, DIFFERENT from g (3 levels, additive -> different intercepts)
#     - z : numeric   held var, NOT shown -> imputed at mean   (~50)
#     - w : factor    held var, NOT shown -> imputed at mode   ("w1")
#     - s : character held var, NOT shown -> imputed at mode   ("s1")
#   Plot: facet_wrap(~f); color = g; dashed lines (linetype) of linewidth 1.2 (styling).
#
#   This is the integration stress test: grouping + faceting together is the combination
#   the SliceLayer structural issue (see for_devs/known_issues.Rmd) is expected to break.

source("testing/_setup.R")
set.seed(123)

n <- 240
x <- runif(n, 0, 10)
g <- factor(sample(c("G1", "G2"), n, replace = TRUE))
f <- factor(sample(c("F1", "F2", "F3"), n, replace = TRUE))
z <- runif(n, 0, 100)
w <- factor(sample(c("w1", "w2"), n, replace = TRUE, prob = c(0.7, 0.3)))
s <- sample(c("s1", "s2"), n, replace = TRUE, prob = c(0.6, 0.4))

slope <- c(G1 = 1, G2 = 3)[as.character(g)]
inter <- c(F1 = 0, F2 = 10, F3 = 20)[as.character(f)]
y <- inter + slope * x + 0.05 * z + rnorm(n, sd = 1)

dat <- data.frame(x, y, g, f, z, w, s, stringsAsFactors = FALSE)
model <- lm(y ~ x * g + f + z + w + s, data = dat)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ f) +
  geom_slice(model, linetype = "dashed", linewidth = 1.2) +
  labs(title = "gs_17: All features — group (g) + facet (f) + imputed z/w/s + styling",
       subtitle = "EXPECT: per facet, two dashed lines by g (slopes ~1 & ~3); z/w/s imputed, not shown")
p
