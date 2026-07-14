# gs_18 REFERENCE — impute-type coverage ground truth. Single additive slice with
# z_num / w_fac / s_chr held at mean / mode / mode (the values geom_slice imputes).
source("tests/reference/_ref_helpers.R")
set.seed(123)

n <- 120
x <- runif(n, 0, 10)
z_num <- runif(n, 0, 100)
w_fac <- factor(sample(c("a", "b", "c"), n, replace = TRUE, prob = c(0.6, 0.25, 0.15)))
s_chr <- sample(c("p", "q"), n, replace = TRUE, prob = c(0.7, 0.3))
y <- 2 * x + 0.1 * z_num + rnorm(n)

dat <- data.frame(x, y, z_num, w_fac, s_chr, stringsAsFactors = FALSE)
model <- lm(y ~ x + z_num + w_fac + s_chr, data = dat)

mode_chr <- function(v) names(which.max(table(v)))
ref <- ref_slice(model, dat, "x", held = list(
  z_num = mean(z_num),                                  # numeric   -> mean
  w_fac = factor(mode_chr(w_fac), levels = levels(w_fac)),  # factor    -> mode
  s_chr = mode_chr(s_chr)                               # character -> mode
))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_18 REFERENCE — impute types (numeric mean, factor/character mode)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_18_impute_types.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_18_impute_types.png")
