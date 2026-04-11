
# This is a very quick rough sketch to convey a concept
# Not sure how overriding goes in R (autoplot is an existing function)
# The feasts/ggtime package does this, where it is overridden
#   when a certain type is passed, so that might be a good example
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
