# CASE: cond_band
# A band that can't be resolved warns and the line is drawn without it; a
# band over the data range says which range it used.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ * drv + cyl + year, data = mpg)
coloured <- function(...) function() {
  ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) + geom_slice(...)
}

covers("shared.band.unresolvable", "shared.band.range")

raises("band_range_message", coloured(lm(hwy ~ displ * drv + cyl, mpg), band = "cyl"),
       "message", "Band range for `cyl` not specified")
raises("band_true_several_multi", coloured(model, band = TRUE,
                                           predict_vars = list(cyl = c(4, 8), year = c(1999, 2008))),
       "warning", "band = TRUE is ambiguous: several")
raises("band_true_no_candidate", coloured(lm(hwy ~ displ * drv, mpg), band = TRUE),
       "warning", "no variable is available")
raises("band_true_several_candidates", coloured(model, band = TRUE),
       c("warning", "message", "message"), "band = TRUE is ambiguous: any of")
raises("band_not_predictor", coloured(model, band = "cty"),
       c("warning", "message", "message"), '"cty" is not a predictor')
raises("band_on_x", coloured(model, band = "displ"),
       c("warning", "message", "message"), "is on the x-axis")
raises("band_pinned", coloured(model, band = "drv"),
       c("warning", "message", "message"), "used by the plot's grouping or faceting")
raises("band_not_numeric", function() {
  ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy)) + geom_slice(lm(hwy ~ displ + drv, mpg), band = "drv")
}, c("warning", "message"), "is not numeric, so it has no range")
