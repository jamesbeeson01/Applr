# gs_17 REFERENCE — full-feature integration ground truth (no geom_slice, no geom_smooth).
# Per facet (f) and group (g): a line over that cell's own x range, with z/w/s held at the
# same defaults geom_slice uses (numeric -> mean, factor/character -> mode).
source("tests/reference/_ref_helpers.R")
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

# Defaults geom_slice would impute for the held (not-shown) predictors.
mode_chr <- function(v) names(which.max(table(v)))
held <- list(
  z = mean(z),                                  # numeric   -> mean
  w = factor(mode_chr(w), levels = levels(w)),  # factor    -> mode
  s = mode_chr(s)                               # character -> mode
)

# One line per (facet f, group g) cell, over that cell's own x range (group-range rule).
cells <- expand.grid(fv = levels(f), gv = levels(g), stringsAsFactors = FALSE)
ref <- do.call(rbind, Map(function(fv, gv) {
  sub <- dat[dat$f == fv & dat$g == gv, ]
  d <- ref_slice(model, sub, "x",
                 held = c(held, list(g = factor(gv, levels = levels(g)),
                                     f = factor(fv, levels = levels(f)))))
  d$f <- factor(fv, levels = levels(f))
  d$g <- factor(gv, levels = levels(g))
  d
}, cells$fv, cells$gv))

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ f) +
  geom_line(data = ref, aes(x, .pred, color = g), linetype = "dashed", linewidth = 1.2) +
  labs(title = "gs_17 REFERENCE — all features (group + facet + imputed z/w/s + styling)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_17_all_features.png", plot = p, width = 10, height = 4)
message("OK: tests/reference/gs_17_all_features.png")
