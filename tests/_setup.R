# _setup.R — shared setup, sourced as the first line of every test case.
#
# This file only loads the package and defines helpers. It deliberately does
# NOT generate data: each case creates its own data (with its own seed) so
# that adding, editing, or deleting one case can never affect another, and so
# the reference images in testing/reference/ stay valid.
#
# Paths are relative to the package root — run everything from there.

if (!"Applr" %in% loadedNamespaces()) {
  suppressMessages(devtools::load_all(".", quiet = TRUE))
}
suppressPackageStartupMessages(library(ggplot2))

# try_show(expr) — run one step of a console case. Prints the visible result,
# or the error/warning/message it raises, then lets the rest of the file keep
# running (a bare error would abort the script at the first failing call).
# ggplots are printed inside the tryCatch because their errors surface at
# print time, not at construction time.
try_show <- function(expr) {
  tryCatch(
    withCallingHandlers(
      {
        out <- withVisible(expr)
        if (out$visible) print(out$value)
      },
      warning = function(w) {
        cat("Warning:", conditionMessage(w), "\n")
        invokeRestart("muffleWarning")
      },
      message = function(m) {
        cat("Message:", sub("\n+$", "", conditionMessage(m)), "\n")
        invokeRestart("muffleMessage")
      }
    ),
    error = function(e) cat("Error:", conditionMessage(e), "\n")
  )
  invisible(NULL)
}

# parse_case_header() and other package-free helpers live in _helpers.R so
# report.Rmd can use them without loading the package.
source("testing/_helpers.R")
