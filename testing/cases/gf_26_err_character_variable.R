# CASE: gf_26_err_character_variable
# TYPE: console
# FUNC: geom_fit
# EXPECT: Model contains a character predictor and no new_data is given.
#         Either impute it or fail with a clear message. Currently errors
#         "object 'char_var' not found".

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_char <- data.frame(y = y, x = x,
                      char_var = as.character(rep(c("a", "b"), length.out = n)))
model <- lm(y ~ x + char_var, data = df_char)

try_show(ggplot(df_char, aes(x, y)) +
           geom_point() +
           geom_fit(model))
