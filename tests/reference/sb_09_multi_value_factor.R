# sb_09 REFERENCE — two unlabeled slices (x2 = 0, 4) with factor g held at its
# most common level; subtitle values line lists both: multi-value x2 joined
# with commas, factor quoted ("held at: x2 = 0, 4; g = \"A\"").
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
g <- factor(sample(c("A", "A", "B"), n, replace = TRUE))
y <- x + 2 * x2 + ifelse(g == "A", 0, 4) + rnorm(n)
dat <- data.frame(x, x2, g, y)
model <- lm(y ~ x + x2 + g, data = dat)

g_mode <- names(which.max(table(dat$g)))
lines <- do.call(rbind, lapply(c(0, 4), function(v) {
  s <- ref_slice(model, dat, "x",
                 held = list(x2 = v, g = factor(g_mode, levels = levels(dat$g))))
  s$grp <- v
  s
}))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines, aes(x, .pred, group = grp),
            color = "skyblue", linewidth = 1) +
  labs(title = "sb_09 REFERENCE — multi-value x2 and imputed factor g",
       subtitle = paste0(ref_equation(model), "\n",
                         ref_held_line(list(x2 = c(0, 4), g = g_mode))))

ggsave("tests/reference/sb_09_multi_value_factor.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/sb_09_multi_value_factor.png")
