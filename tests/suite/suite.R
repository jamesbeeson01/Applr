# Agent command line for the judged-output suite. Run from the package root:
#   Rscript tests/suite/suite.R run
#   Rscript tests/suite/suite.R list
#   Rscript tests/suite/suite.R diff <id>
#   Rscript tests/suite/suite.R approve <id> "<note>"
#   Rscript tests/suite/suite.R reject  <id> "<note>"

suppressMessages(pkgload::load_all(".", quiet = TRUE))
for (f in c("fingerprint", "status", "store")) source(file.path("tests/suite", paste0(f, ".R")))

args <- commandArgs(trailingOnly = TRUE)
cmd <- if (length(args)) args[[1]] else "list"
switch(cmd,
  run = {
    r <- run_suite()
    for (id in names(r)) cat(sprintf("%-40s %s\n", id, r[[id]]))
  },
  list = {
    ids <- list_unreviewed()
    if (length(ids)) cat("Unreviewed:", ids, sep = "\n  ") else cat("No Unreviewed outputs.\n")
  },
  diff = cat(diff_output(args[[2]]), sep = "\n"),
  approve = , reject = {
    note <- if (length(args) >= 3) args[[3]] else ""
    agent_decide(args[[2]], cmd, note)
    cat(args[[2]], "->", read_state(suite_paths())[[args[[2]]]]$status, "\n")
  },
  stop("Unknown command: ", cmd, call. = FALSE)
)
