# CASE: ap_14_mapping_nonmodel_var
# TYPE: visual
# FUNC: autoplot
# EXPECT: mapping resolves against the model's FULL data frame, not just the
#         formula variables, so aes(color = factor(cyl)) works even though the
#         model (mpg ~ log(disp)) never mentions cyl. This is the call that
#         used to error with `cyl` not found. Scatter of disp vs mpg colored by
#         factor(cyl) (levels 4/6/8, legend). cyl is NOT a model predictor, so
#         it does not change the slice — every group shares the same log(disp)
#         curve. geom_slice draws each group over its own disp range, so the
#         curve appears as one continuous line split into three colors: red
#         (4-cyl, low disp) -> green (6-cyl, mid) -> blue (8-cyl, high disp).
#         The x-axis is the model's only predictor (disp), so nothing is
#         imputed and the case is silent (summary = FALSE).

source("tests/_setup.R")

model <- lm(mpg ~ log(disp), data = mtcars)

p <- autoplot(model, mapping = aes(color = factor(cyl)), summary = FALSE) +
  labs(title = "ap_14: autoplot(lm) mapping a non-model column",
       subtitle = "EXPECT: disp x-axis, cyl-colored scatter, one curve split into 3 colors")
p
