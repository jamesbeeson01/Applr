# CASE: ap_04_transformed_predictor
# TYPE: visual
# FUNC: autoplot
# EXPECT: autoplot's all.vars() strips the predictor transform, so the x-axis
#         is RAW disp even though the model is mpg ~ log(disp). One smooth
#         logarithmic curve: steep drop at small disp, flattening at large
#         disp. No errors; no imputation messages.

source("testing/_setup.R")

model <- lm(mpg ~ log(disp), data = mtcars)

p <- autoplot(model) +
  labs(title = "ap_04: autoplot(lm), transformed predictor (mpg ~ log(disp))",
       subtitle = "EXPECT: logarithmic curve on the raw disp axis")
p
