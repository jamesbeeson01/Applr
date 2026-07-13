# _helpers.R — package-free helpers shared by run.R and report.Rmd.
#
# Deliberately does NOT load Applr: report.Rmd sources only this file, so
# knitting the report never depends on (possibly stale) package code in the
# knitting session — all case execution happens inside `Rscript testing/run.R`.
# Paths are relative to the package root.

# parse_case_header(file) — read the structured comment header of a case file.
# Recognized keys (see testing/README.md):
#   # CASE: <id>        # TYPE: visual | console     # FUNC: <function under test>
#   # SIZE: <w>x<h>     # EXPECT: <what a correct result looks like>
# EXPECT may continue over following comment lines until the next key or blank.
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
