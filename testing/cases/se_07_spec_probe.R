# CASE: se_07_spec_probe
# TYPE: console
# FUNC: slice_explore
# EXPECT: A deterministic probe of the exploration spec that drives the
#         sliders. Slider grids: hp and wt, 37 steps each, starting exactly
#         at their means (146.7 / 3.217). Every "max |...|" line must be 0:
#         the precomputed curve at any slider combination IS predict() at
#         those values (same linear indexing the browser JS uses), and the
#         starting combination reproduces the static autoplot's imputed
#         slice. If the JS combiner's indexing convention or geom_slice's
#         crossing order ever changes, these zeros break.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + wt, data = mtcars)
spec <- suppressMessages(Applr:::explore_spec(model, rlang::quo(TRUE)))

s_hp <- spec$sliders[[1]]
s_wt <- spec$sliders[[2]]
cat("sliders:", s_hp$var, s_wt$var, "\n")
cat("sizes:", paste(spec$sizes, collapse = " x "), "\n")
cat("curves:", length(spec$curves),
    " points per curve:", length(spec$curves[[1]]$x), "\n")
cat("hp start:", format(s_hp$values[s_hp$init + 1], digits = 7),
    " (mean:", format(mean(mtcars$hp), digits = 7), ")\n")
cat("wt start:", format(s_wt$values[s_wt$init + 1], digits = 7),
    " (mean:", format(mean(mtcars$wt), digits = 7), ")\n")

# The browser JS picks curve  idx = i_hp * n_wt + i_wt  (0-based, row-major).
# Re-derive several combinations with predict() and demand exact agreement.
cv <- spec$curves[[1]]
combo_diff <- function(i_hp, i_wt) {
  idx <- i_hp * spec$sizes[2] + i_wt + 1
  manual <- predict(model, newdata = data.frame(
    disp = cv$x, hp = s_hp$values[i_hp + 1], wt = s_wt$values[i_wt + 1]))
  max(abs(cv$y[[idx]] - signif(manual, 7)))
}
cat("max |curve - predict| at corners and middle:",
    max(combo_diff(0, 0), combo_diff(36, 36), combo_diff(0, 36),
        combo_diff(36, 0), combo_diff(18, 9)), "\n")

# The sliders' starting combination must BE the static slice: predictions
# with every hidden variable at its mean, geom_slice's imputed default.
init_idx <- (s_hp$init * spec$sizes[2] + s_wt$init) + 1
static <- predict(model, newdata = data.frame(
  disp = cv$x, hp = mean(mtcars$hp), wt = mean(mtcars$wt)))
cat("max |start curve - static autoplot slice|:",
    max(abs(cv$y[[init_idx]] - signif(static, 7))), "\n")
