# gs_18_impute_types.R
# EXPECT: Impute-type coverage, isolated from grouping/faceting. Model:
#   y ~ x + z_num + w_fac + s_chr   — a single additive slice.
#   x is the axis; the other three predictors are NOT shown and must be imputed:
#     z_num (numeric)   -> mean  (~50)
#     w_fac (factor)    -> mode  ("a")
#     s_chr (character) -> mode  ("p")
#   Result: ONE straight line, plus THREE console messages naming each imputed value.
#
#   COVERAGE NOTE: geom_slice currently implements only mean (numeric) and mode
#   (factor/character). min / max / median imputation are NOT implemented (see the
#   impute item in for_devs/dev_todo.Rmd) and therefore cannot be tested yet — when
#   that feature lands, add gs_ cases exercising each new impute method.
#   Compare against testing/reference/gs_18_impute_types.png.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 120
x <- runif(n, 0, 10)
z_num <- runif(n, 0, 100)                                                                # -> mean
w_fac <- factor(sample(c("a", "b", "c"), n, replace = TRUE, prob = c(0.6, 0.25, 0.15)))  # -> "a"
s_chr <- sample(c("p", "q"), n, replace = TRUE, prob = c(0.7, 0.3))                       # -> "p"
y <- 2 * x + 0.1 * z_num + rnorm(n)

dat <- data.frame(x, y, z_num, w_fac, s_chr, stringsAsFactors = FALSE)
model <- lm(y ~ x + z_num + w_fac + s_chr, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_18: Impute types — numeric (mean), factor (mode), character (mode)",
       subtitle = "EXPECT: one line; 3 console messages for imputed z_num / w_fac / s_chr")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_18_impute_types.png", plot = p, width = 7, height = 5)
message("OK: testing/output/gs_18_impute_types.png")
