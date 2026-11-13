# The release check: run before a CRAN submission, on the machine the
# approvals were made on. From the package root:
#   Rscript tests/suite/release.R
# Fails while any output is Unreviewed, Rejected or Agent approved, or its
# fingerprint here differs from the recorded one (run suite.R run first).
# Then runs the release audit: every state is rendered again and compared
# with the view kept at its human approval. Needs chromote with Chrome for
# interactive states, and png.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/suite/load.R")
load_suite("tests/suite")

rows <- check_run()
bad <- Filter(function(r) release_verdict(r$status_here, r$case_failed) == "fail" || !r$match, rows)
for (r in bad) {
  cat(sprintf("  %-45s %s\n", r$id,
              if (r$case_failed) "case expectations fail"
              else if (!r$match) "fingerprint differs from the recorded one; run suite.R run"
              else r$status_here))
}

audit <- release_audit(rows)
changed <- audit[audit != "same"]
for (id in names(changed)) cat(sprintf("  %-45s audit: %s\n", id, changed[[id]]))

cat(sprintf("\n%d outputs: %d not Human approved, %d failing the audit\n",
            length(rows), length(bad), length(changed)))
if (length(bad) || length(changed)) {
  cat("Release check FAILED. Don't submit to CRAN.\n")
  quit(status = 1)
}
cat("Release check passed.\n")
