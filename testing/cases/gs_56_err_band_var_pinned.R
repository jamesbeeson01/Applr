# CASE: gs_56_err_band_var_pinned
# TYPE: console
# FUNC: geom_slice
# EXPECT: A clear, student-readable warning: band = "drv" names a predictor
#         pinned per group by aes(color = drv), so each line already uses its
#         own drv value and it cannot band, so no band is drawn. The hint
#         should name predictors a band could actually use (here cyl) and
#         offer band = TRUE. The slice lines still draw — no further errors.

source("testing/_setup.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)

try_show(ggplot(mpg, aes(displ, hwy, color = drv)) +
           geom_point() +
           geom_slice(model, band = "drv"))
