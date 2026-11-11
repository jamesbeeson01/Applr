# When and on which commit a run happened, for the reports the review page
# shows. Sourced by test.R and mutate.R, and by load_suite().

now_stamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")

git_commit <- function() {
  git <- function(...) tryCatch(suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = FALSE)),
                                error = function(e) character())
  sha <- git("rev-parse", "--short", "HEAD")
  if (!length(sha)) return("unknown")
  if (length(git("status", "--porcelain"))) paste(sha[1], "+ uncommitted changes") else sha[1]
}
