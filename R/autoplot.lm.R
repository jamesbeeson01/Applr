
# This is a very quick rough sketch to convey a concept
# The method must be registered (S3method(autoplot, lm) in NAMESPACE, via the
#   roxygen @export below) or autoplot(model) falls through to ggplot2's
#   autoplot.default — the feasts/ggtime packages register theirs the same way
#' @export
#' @noRd
autoplot.lm <- function(model) {
  v <- all.vars(formula(model))

  ggplot(eval(model$call$data), aes(!!as.name(v[2]), !!as.name(v[1]))) +
    geom_point() +
    geom_slice(model) +
    theme_lc()
}

# model$call$data - the data used in the lm (as a symbol)
# eval() - evaluate the symbol to pass the literal data.frame
# all.vars() - gets variables/columns used (with the functions applied to them)
# as.name() - convert from string to symbol
# !! - evaluate immediately, don't look for column "v[2]"
