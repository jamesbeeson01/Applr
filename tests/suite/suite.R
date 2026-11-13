# Agent command line for the judged-output suite. Run from the package root:
#   Rscript tests/suite/suite.R run
#   Rscript tests/suite/suite.R list
#   Rscript tests/suite/suite.R diff <id>
#   Rscript tests/suite/suite.R approve <id> "<note>"
#   Rscript tests/suite/suite.R reject  <id> "<note>"
#   Rscript tests/suite/suite.R variant <bundle> <id> "<what differs>"
# `variant` approves a platform variant from a CI run's downloaded bundle.
# Each prints the review page link for the outputs it names; the page itself
# is started with tests/suite/review.R.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/suite/load.R")
load_suite("tests/suite")

args <- commandArgs(trailingOnly = TRUE)
cmd <- if (length(args)) args[[1]] else "list"
switch(cmd,
  run = {
    r <- run_suite()
    for (id in names(r)) cat(sprintf("%-40s %s\n", id, r[[id]]))
    cat("\nReview page:", review_url(), "\n")
  },
  list = {
    ids <- list_unreviewed()
    if (length(ids)) {
      cat("Unreviewed:\n")
      cat(sprintf("  %-40s %s\n", ids, vapply(ids, review_url, "")), sep = "")
    } else {
      cat("No Unreviewed outputs.\n")
    }
  },
  diff = cat(diff_output(args[[2]]), sep = "\n"),
  approve = , reject = {
    note <- if (length(args) >= 3) args[[3]] else ""
    agent_decide(args[[2]], cmd, note)
    cat(args[[2]], "->", review_records()[[args[[2]]]]$status, "\n  ", review_url(args[[2]]), "\n")
  },
  variant = {
    rec <- agent_approve_variant(args[[2]], args[[3]], if (length(args) >= 4) args[[4]] else "")
    cat(args[[3]], "-> platform variant approved for", names(rec$variants), "\n")
  },
  stop("Unknown command: ", cmd, call. = FALSE)
)
