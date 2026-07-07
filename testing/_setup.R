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

# parse_case_header(file) — read the structured comment header of a case file.
# Recognized keys (see testing/README.md):
#   # CASE: <id>        # TYPE: visual | console     # FUNC: <function under test>
#   # SIZE: <w>x<h>     # EXPECT: <what a correct result looks like>
# EXPECT may continue over following comment lines until the next key or blank.
# Used by both run.R and report.Rmd.
parse_case_header <- function(file) {
  lines <- readLines(file, n = 40, warn = FALSE)
  lines <- lines[seq_len(max(0, which(!grepl("^#", lines))[1] - 1))]  # leading comment block only
  get_key <- function(key) {
    hit <- grep(sprintf("^# *%s:", key), lines)
    if (length(hit) == 0) return(NA_character_)
    val <- sub(sprintf("^# *%s: *", key), "", lines[hit[1]])
    # continuation lines: comments that don't start a new KEY
    i <- hit[1] + 1
    while (i <= length(lines) && grepl("^# +", lines[i]) &&
           !grepl("^# *[A-Z]+:", lines[i])) {
      val <- paste(val, trimws(sub("^# *", "", lines[i])))
      i <- i + 1
    }
    trimws(val)
  }
  size <- get_key("SIZE")
  wh <- if (is.na(size)) c(7, 5) else as.numeric(strsplit(size, "x")[[1]])
  list(
    id     = sub("\\.R$", "", basename(file)),
    type   = ifelse(is.na(get_key("TYPE")), "visual", get_key("TYPE")),
    func   = ifelse(is.na(get_key("FUNC")), "other", get_key("FUNC")),
    expect = get_key("EXPECT"),
    width  = wh[1],
    height = wh[2]
  )
}
