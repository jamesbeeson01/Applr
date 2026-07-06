# _ref_helpers.R — shared ground-truth helpers for the geom_slice reference plots.
#
# References are built WITHOUT the Applr package: an explicit newdata grid fed to
# predict() (== model.matrix %*% coef(model)) — the exact lm() coefficients, with
# no geom_smooth(). Each reference mirrors the styling of its testing/cases/ plot
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

dir.create("testing/reference", showWarnings = FALSE, recursive = TRUE)
