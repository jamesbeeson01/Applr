# CASE: ap_16_err_xaxis_and_mapping_x
# TYPE: console
# FUNC: autoplot
# EXPECT: Setting the x-axis twice — once via the deprecated `xaxis` and once
#         via `mapping = aes(x = ...)` — is ambiguous, so autoplot errors after
#         warning that `xaxis` is deprecated. Output: the deprecation warning
#         then an error telling the user to drop `xaxis`.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

try_show(autoplot(model, mapping = aes(x = hp), xaxis = "disp", summary = FALSE))
