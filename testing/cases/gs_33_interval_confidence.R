# CASE: gs_33_interval_confidence
# TYPE: visual
# FUNC: geom_slice
# EXPECT: KNOWN ISSUE (unimplemented feature, dev_todo.Rmd: "Add confidence
#         and prediction interval to geom_slice"). mtcars disp vs mpg, model
#         mpg ~ disp + hp sliced at hp = 110: one straight downward line with
#         a NARROW confidence ribbon around it (see reference). Currently
#         geom_slice ignores `interval` with an "unknown parameters" warning
#         and draws only the line, so the output lacks the ribbon.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model, predict_vars = list(hp = 110), interval = "confidence")
