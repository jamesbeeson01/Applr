# Fingerprints every judged output and compares it with the committed review
# state, writing nothing to it. Run from the package root:
#   Rscript tests/suite/ci.R [out_dir]
# Writes out_dir/report.json (one row per output), out_dir/session.txt, and
# a bundle of the forms and views of every output whose fingerprint differs.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/suite/load.R")
load_suite("tests/suite")

args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args)) args[[1]] else file.path("tests/output", "ci")
unlink(out_dir, recursive = TRUE)
dir.create(out_dir, recursive = TRUE)

rows <- check_run()
notes <- write_bundle(rows, out_dir)
writeLines(platform_info(), file.path(out_dir, "session.txt"))
report <- list(when = now_stamp(), commit = git_commit(), platform = R.version$platform,
               outputs = unname(lapply(rows, function(r) { r$note <- notes[[r$id]] %||% ""; r })))
jsonlite::write_json(report, file.path(out_dir, "report.json"), pretty = TRUE, auto_unbox = TRUE)

n_match <- sum(vapply(rows, `[[`, TRUE, "match"))
cat(sprintf("%d of %d outputs match the recorded fingerprint\n", n_match, length(rows)))
for (r in rows) if (!r$match) {
  cat(sprintf("  %-45s %s%s\n", r$id, if (r$case_failed) "CASE FAILED" else "differs:",
              if (r$case_failed) "" else paste("", paste(r$parts_differing, collapse = ", "))))
}
