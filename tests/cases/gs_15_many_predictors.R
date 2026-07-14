# CASE: gs_15_many_predictors
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mtcars scatter (disp vs mpg). Model has 4 predictors: disp + hp + wt + drat.
#         predict_vars holds hp, wt, and drat at specific values.
#         One nearly-flat (slightly rising) line: with hp/wt/drat held, disp's
#         partial coefficient is slightly positive (wt absorbs the downward trend).
#         Tests that geom_slice can handle many held variables simultaneously.
#         No errors.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp + wt + drat, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model,
             predict_vars = list(hp = 110, wt = 3.0, drat = 3.5),
             color = "darkorange", linewidth = 1.2) +
  labs(title = "gs_15: Many predictors — mpg ~ disp + hp + wt + drat",
       subtitle = "EXPECT: One line, hp=110, wt=3.0, drat=3.5 held. No errors.")
p
