# Unit tests for the suite's own infrastructure. Run from the package root:
#   Rscript tests/suite/test.R
# Writes tests/suite/test_report.json (date, commit, every test's result),
# which the review page shows.

source("tests/suite/stamp.R")
res <- testthat::test_dir("tests/suite/unit", reporter = "summary", stop_on_failure = FALSE)
df <- as.data.frame(res)
bad <- df$failed > 0 | df$error
report <- list(
  when = now_stamp(), commit = git_commit(), tests = nrow(df), failed = sum(bad),
  skipped = sum(df$skipped), seconds = round(sum(df$real), 1),
  results = lapply(seq_len(nrow(df)), function(i) list(
    file = df$file[i], test = df$test[i], expectations = df$nb[i],
    passed = !bad[i], skipped = df$skipped[i], seconds = round(df$real[i], 2)
  ))
)
jsonlite::write_json(report, "tests/suite/test_report.json", pretty = TRUE, auto_unbox = TRUE)
if (any(bad)) quit(status = 1)
