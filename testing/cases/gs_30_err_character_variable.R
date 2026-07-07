# CASE: gs_30_err_character_variable
# TYPE: console
# FUNC: geom_slice
# EXPECT: geom_slice SUPPORTS character predictors: it should impute char_var
#         by mode ("a") with a console message and draw the slice without
#         errors. (See gs_18 for the visual impute-type coverage.)

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
           geom_slice(model))
