# CASE: dw_16_err_character_variable
# TYPE: console
# FUNC: drawit
# EXPECT: Model contains a character predictor and it is not pinned via ...:
#         a clear message telling the user to supply a value. Currently warns
#         'char_var value not specified; enter value as one of the following:
#         ""' — the list of valid values is empty, which needs fixing.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_char <- data.frame(y = y, x = x,
                      char_var = as.character(rep(c("a", "b"), length.out = n)))
model <- lm(y ~ x + char_var, data = df_char)

plot(x, y, main = "scaffold plot")
try_show(drawit(model, xaxis = "x"))
