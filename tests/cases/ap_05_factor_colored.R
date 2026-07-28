# CASE: ap_05_factor_colored
# TYPE: visual
# FUNC: autoplot
# EXPECT: iris scatter (Petal.Length vs Sepal.Length). Species is a non-numeric
#         second predictor, so autoplot shows it as colour rather than imputing
#         it: THREE slice lines (setosa/versicolor/virginica), each over its own
#         petal range. Console: one "Coloured by Species" message.

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Petal.Length + Species, data = iris)

p <- autoplot(model, summary = FALSE) +
  labs(title = "ap_05: autoplot(lm), factor covariate coloured (Sepal.Length ~ Petal.Length + Species)",
       subtitle = "EXPECT: three lines, one per Species")
p
