# _ref_helpers.R — shared ground-truth helpers for the geom_slice reference plots.
#
# References are built WITHOUT the Applr package: an explicit newdata grid fed to
# predict() (== model.matrix %*% coef(model)) — the exact lm() coefficients, with
# no geom_smooth(). Each reference mirrors the styling of its tests/cases/ plot
# so the two PNGs can be compared side by side.

suppressPackageStartupMessages(library(ggplot2))

# Build one slice line.
#   model          : the fitted lm
#   data           : data whose `xvar` range the line should span. For grouped or
#                    faceted cases pass the group subset, per the decisions.Rmd
#                    rule that a line spans its group's range, not the whole panel.
#   xvar           : name of the predictor on the x-axis
#   held           : named list of fixed values for the other predictors
#   back_transform : function applied to predictions (identity, exp, \(z) z^2, ...)
#   n              : number of points along the line
# Returns a data frame with the `xvar` column and `.pred`.
ref_slice <- function(model, data, xvar, held = list(),
                      back_transform = identity, n = 200) {
  xr <- range(data[[xvar]], na.rm = TRUE)
  nd <- setNames(data.frame(seq(xr[1], xr[2], length.out = n)), xvar)
  for (v in names(held)) nd[[v]] <- held[[v]]
  nd$.pred <- back_transform(predict(model, newdata = nd))
  nd
}

# Human-readable equation of a fitted lm, built directly from coef(model)
# (independent re-derivation of what a subtitle's model line should say).
# Format: "y = 0.0288 + 0.996*x + 2.02*x2", coefficients at 3 sig figs.
# Terms are named by their coefficient (design-matrix) names, so factor
# predictors show one term per dummy level (e.g. "2.1*gB").
ref_equation <- function(model) {
  co <- signif(coef(model)[!is.na(coef(model))], 3)
  rhs <- paste0(co[-1], "*", names(co)[-1], collapse = " + ")
  gsub("\\+ -", "- ",
       paste0(deparse(formula(model)[[2]]), " = ", co[[1]], " + ", rhs))
}

# One held value formatted for a subtitle: 4 sig figs for numbers, quoted
# strings for factors/characters (matches geom_slice's console messages).
ref_value <- function(v) {
  if (is.numeric(v)) format(signif(v, 4)) else paste0('"', v, '"')
}

# The "held at: x2 = 2.507; g = \"A\"" line from a named list of held values.
# Multi-value variables join with ", " (e.g. "x2 = 0, 4").
ref_held_line <- function(held) {
  parts <- vapply(names(held), function(v) {
    paste0(v, " = ", paste(vapply(held[[v]], ref_value, character(1)),
                           collapse = ", "))
  }, character(1))
  paste0("held at: ", paste(parts, collapse = "; "))
}

dir.create("tests/reference", showWarnings = FALSE, recursive = TRUE)
