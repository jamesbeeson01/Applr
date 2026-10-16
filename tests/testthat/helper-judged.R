# Declares a judged output from inside a case. A no-op unless the dev-only
# suite runner (tests/suite/) has installed a registry, so it is harmless
# under R CMD check.
judged_output <- function(name, plot) {
  registry <- getOption("applr.judged_registry")
  case <- getOption("applr.judged_case")
  if (is.environment(registry) && !is.null(case)) {
    assign(paste0(case, "/", name), plot, envir = registry)
  }
  invisible(plot)
}
