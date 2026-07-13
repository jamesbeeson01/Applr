# CASE: sb_05_prepend_append
# TYPE: visual
# FUNC: geom_slice_subtitle
# EXPECT: The simple-control version: prepend/append are plain strings pasted
#         around the default subtitle. With prepend = "Model: " and
#         append = " (mean-imputed)", the subtitle reads
#         "Model: <equation>\nheld at: x2 = <mean> (mean-imputed)" —
#         prepend before the first line, append after the last, default two-
#         line layout otherwise unchanged.
#         Console message: x2 not specified, held at its mean (~2.385).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model) +
  geom_slice_subtitle(prepend = "Model: ", append = " (mean-imputed)") +
  labs(title = "sb_05: prepend/append text around the default subtitle")
p
