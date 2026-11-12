# CASE: cond_imputation
# Imputation messages: one per imputed predictor, once per layer however
# many panels and groups, in each engine's own wording.

mpg <- ggplot2::mpg
d <- data.frame(x = 1:9, f = factor(c("a", "b", "b", "c", "c", "c", "a", "b", "c")),
                s = c("p", "q", "q", "q", "p", "q", "p", "q", "q"), y = c(3, 5, 4, 8, 9, 12, 10, 13, 16))

covers("shared.imputation.message", "shared.imputation.once-per-layer",
       "shared.imputation.engines-differ", "geom_slice_text.silent-rebuild",
       "geom_slice_subtitle.no-repeat-messages")

raises("factor_and_character", function() {
  ggplot2::ggplot(d, ggplot2::aes(x, y)) + geom_slice(lm(y ~ x + f + s, d))
}, c("message", "message"), c('Used most common: "c"', 'Used most common: "q"'))
raises("once_per_layer", function() {
  ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) +
    geom_slice(lm(hwy ~ displ * drv + cyl + year, mpg)) + ggplot2::facet_wrap(~fl)
}, c("message", "message"), c("`cyl`", "`year`"))
raises("companions_stay_quiet", function() {
  ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy)) +
    geom_slice(lm(hwy ~ displ + cyl + year, mpg), predict_vars = list(year = c(1999, 2008))) +
    geom_slice_text() + geom_slice_subtitle() + geom_slice_caption()
}, "message", "Value for `cyl` not specified")
raises("slice_2d_wording", function() {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  slice_2d(lm(y ~ x + f, d), x_axis = "x")
}, "message", "Value for `f` not specified - Used first value: a", format = FALSE)
raises("slice_2d_character", function() slice_2d(lm(y ~ x + s, d), x_axis = "x"),
       "error", 'unsupported class "character"')
