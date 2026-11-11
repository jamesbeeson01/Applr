# Sources the suite into the global environment: the core, then every
# registered output type. `dir` is the suite folder, so a copy of the suite
# (as the mutation check makes) loads its own files.
load_suite <- function(dir = "tests/suite") {
  for (f in c("stamp", "fingerprint", "types", "status", "store", "views", "inventory", "server")) {
    sys.source(file.path(dir, paste0(f, ".R")), envir = globalenv())
  }
  source_output_types(file.path(dir, "types"))
  invisible(dir)
}
