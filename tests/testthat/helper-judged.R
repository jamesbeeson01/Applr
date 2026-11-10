# Declares a judged output from inside a case. `type` names a registered
# output type, or is worked out by the suite when the object alone says it
# (a ggplot, a plotly widget). `states` are the case's declared states, such
# as camera presets. A no-op unless the dev-only suite runner (tests/suite/)
# has installed a registry, so it is harmless under R CMD check.
judged_output <- function(name, object, type = NULL, states = NULL) {
  registry <- getOption("applr.judged_registry")
  case <- getOption("applr.judged_case")
  if (is.environment(registry) && !is.null(case)) {
    assign(paste0(case, "/", name), list(object = object, type = type, states = states),
           envir = registry)
  }
  invisible(object)
}
