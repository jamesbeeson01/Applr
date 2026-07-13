# CASE: as_16_err_character_variable
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: Model contains a character predictor. Either handle it (impute by
#         mode) or fail with a clear message naming the variable and its
#         class, with a hint about supported types.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_char <- data.frame(y = y, x = x,
                      char_var = as.character(rep(c("a", "b"), length.out = n)))
model <- lm(y ~ x + char_var, data = df_char)

plot(x, y, main = "scaffold plot")
try_show(add_slice_2d(model))
