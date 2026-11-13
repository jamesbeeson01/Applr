# The CI check: fingerprints every judged output, compares it with the
# committed review state (writing nothing to it), and reports each review
# status by the spec's CI policy. Run from the package root:
#   Rscript tests/suite/ci.R [out_dir]
# Writes out_dir/report.json (one row per output), out_dir/session.txt, and
# a bundle of the forms and views of every platform variant. Exits non-zero
# when anything fails. On GitHub it also writes annotations and a summary.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/suite/load.R")
load_suite("tests/suite")

args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args)) args[[1]] else file.path("tests/output", "ci")
unlink(out_dir, recursive = TRUE)
dir.create(out_dir, recursive = TRUE)

rows <- check_run()
notes <- write_bundle(rows, out_dir)
for (id in names(rows)) {
  rows[[id]]$verdict <- ci_verdict(rows[[id]]$status_here, rows[[id]]$case_failed)
  rows[[id]]$note <- notes[[id]] %||% ""
}
failures <- attr(rows, "failures")
writeLines(platform_info(), file.path(out_dir, "session.txt"))
report <- list(when = now_stamp(), commit = git_commit(), platform = R.version$platform,
               platform_name = attr(rows, "platform"), failures = failures,
               outputs = unname(rows))
jsonlite::write_json(report, file.path(out_dir, "report.json"), pretty = TRUE, auto_unbox = TRUE)

verdicts <- vapply(rows, `[[`, "", "verdict")
reason <- function(r) {
  if (r$case_failed) "case expectations fail" else r$status_here
}
cat(sprintf("%s: %d pass, %d warn, %d fail (%d outputs, %d variants)\n", attr(rows, "platform"),
            sum(verdicts == "pass"), sum(verdicts == "warn"), sum(verdicts == "fail"),
            length(rows), sum(!vapply(rows, `[[`, TRUE, "match"))))
for (case in names(failures)) {
  cat("Case ", case, " failed:\n", paste0("  ", failures[[case]], "\n"), sep = "")
}
for (r in rows) if (r$verdict == "fail") cat(sprintf("  FAIL %-45s %s\n", r$id, reason(r)))

if (nzchar(Sys.getenv("GITHUB_ACTIONS"))) {
  for (r in rows) if (r$verdict != "pass") {
    cat(sprintf("::%s title=%s::%s\n", if (r$verdict == "fail") "error" else "warning",
                reason(r), r$id))
  }
  summary <- Sys.getenv("GITHUB_STEP_SUMMARY")
  if (nzchar(summary)) {
    counts <- table(factor(vapply(rows, reason, ""), levels = unique(vapply(rows, reason, ""))))
    lines <- c(sprintf("## Judged outputs on %s", attr(rows, "platform")), "",
               "| Status here | Outputs | CI |", "|---|---|---|",
               sprintf("| %s | %d | %s |", names(counts), as.integer(counts),
                       vapply(names(counts), function(s) {
                         c(pass = "✓", warn = "warning", fail = "✗")[[
                           ci_verdict(s, s == "case expectations fail")]]
                       }, "")))
    variants <- Filter(function(r) !r$match && !r$case_failed, rows)
    if (length(variants)) {
      lines <- c(lines, "", "Platform variants (forms and views in this run's artifact):", "",
                 sprintf("- `%s`: %s differ", vapply(variants, `[[`, "", "id"),
                         vapply(variants, function(r) paste(r$parts_differing, collapse = ", "), "")))
    }
    write(lines, summary, append = TRUE)
  }
}

if (any(verdicts == "fail")) quit(status = 1)
