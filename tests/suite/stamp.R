# When, on which commit and on which suite code a run happened, for the
# reports the review page shows. Sourced by test.R and mutate.R, and by
# load_suite().

now_stamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")

git_commit <- function() {
  git <- function(...) tryCatch(suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = FALSE)),
                                error = function(e) character())
  sha <- git("rev-parse", "--short", "HEAD")
  if (!length(sha)) return("unknown")
  if (length(git("status", "--porcelain"))) paste(sha[1], "+ uncommitted changes") else sha[1]
}

# The files a mutation check's verdict rests on: the suite's R code (its break
# list and unit tests included) and the case files those tests read, found as
# quoted case names in unit/ and types/, plus helper-judged.R. Other cases are
# left out, so adding one doesn't put the report out of date.
suite_code_files <- function(suite_dir = "tests/suite", case_dir = "tests/testthat") {
  code <- list.files(suite_dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
  readers <- code[grepl("^(unit|types)/", substring(code, nchar(suite_dir) + 2))]
  text <- unlist(lapply(readers, readLines, warn = FALSE))
  quoted <- gsub('"', "", unlist(regmatches(text, gregexpr('"[A-Za-z0-9_]+"', text))))
  cases <- file.path(case_dir, paste0("test-case_", unique(quoted), ".R"))
  c(code, cases[file.exists(cases)], file.path(case_dir, "helper-judged.R"))
}

# One hash over those files' names and lines, so line endings don't matter.
# Written in binary, so the hash is the same on Windows as on CI's Linux.
suite_code_hash <- function(suite_dir = "tests/suite", case_dir = "tests/testthat") {
  files <- suite_code_files(suite_dir, case_dir)
  names <- c(substring(files[startsWith(files, suite_dir)], nchar(suite_dir) + 2),
             file.path("cases", basename(files[!startsWith(files, suite_dir)])))
  ord <- order(names, method = "radix")
  tmp <- tempfile()
  on.exit(unlink(tmp))
  con <- file(tmp, "wb")
  writeLines(unlist(Map(function(n, f) c(n, readLines(f, warn = FALSE)), names[ord], files[ord])),
             con, useBytes = TRUE)
  close(con)
  unname(tools::md5sum(tmp))
}
