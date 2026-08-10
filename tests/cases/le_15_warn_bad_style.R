# CASE: le_15_warn_bad_style
# TYPE: console
# FUNC: lm_equation
# EXPECT: An unrecognised `style` is not fatal — it warns in the package's
#         voice, naming the three choices, and writes the equation with the
#         default "prettier". Abbreviations still resolve silently, so
#         style = "br" gives the same equation as style = "brackets".

source("tests/_setup.R")

model <- lm(Sepal.Length ~ Sepal.Width + Species, data = iris)

try_show(lm_equation(model, style = "pretty please"))
try_show(lm_equation(model, style = "br"))
try_show(lm_latex(model, style = 5))
