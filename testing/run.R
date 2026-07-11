# run.R — test runner (terminal / AI entry point). Run from the package root:
#
#   Rscript testing/run.R                  # run every case in testing/cases/
#   Rscript testing/run.R gs_01 err_02     # run specific cases (prefix is enough)
#   Rscript testing/run.R --update err_01  # re-snapshot expected/ output for console case(s)
#
# Visual cases  -> testing/output/<id>.png   (compare by eye against testing/reference/<id>.png)
# Console cases -> testing/output/<id>.txt   (diffed automatically against testing/expected/<id>.txt)
#
# See testing/README.md for the case file format.

source("testing/_setup.R")

args <- commandArgs(trailingOnly = TRUE)
update_expected <- "--update" %in% args
args <- setdiff(args, c("--update", "all"))

all_files <- sort(list.files("testing/cases", pattern = "\\.R$", full.names = TRUE))
if (length(all_files) == 0) stop("No cases in testing/cases/. Run from the package root.")

if (length(args) > 0) {
  keep <- Reduce(`|`, lapply(args, function(a) startsWith(basename(all_files), a)))
  if (!any(keep)) stop("No case matches: ", paste(args, collapse = ", "))
  all_files <- all_files[keep]
}

dir.create("testing/output",   showWarnings = FALSE, recursive = TRUE)
dir.create("testing/expected", showWarnings = FALSE, recursive = TRUE)

run_visual <- function(file, meta) {
  # clear stale outputs for this case, then draw every plot the case makes
  stale <- list.files("testing/output", sprintf("^%s(-\\d+)?\\.png$", meta$id), full.names = TRUE)
  file.remove(stale)
  png(file.path("testing/output", paste0(meta$id, "-%02d.png")),
      width = meta$width, height = meta$height, units = "in", res = 300)
  err <- NULL
  tryCatch(source(file, local = new.env(), echo = FALSE, print.eval = TRUE),
           error = function(e) err <<- conditionMessage(e))
  dev.off()
  made <- list.files("testing/output", sprintf("^%s-\\d+\\.png$", meta$id), full.names = TRUE)
  if (!is.null(err)) {
    file.remove(made)
    return(list(status = "FAIL", msg = err))
  }
  if (length(made) == 0) return(list(status = "FAIL", msg = "case ran but produced no plot"))
  if (length(made) == 1) {
    single <- file.path("testing/output", paste0(meta$id, ".png"))
    file.rename(made, single)
    made <- single
  }
  list(status = "OK", msg = paste(basename(made), collapse = ", "))
}

run_console <- function(file, meta) {
  out_file <- file.path("testing/output",   paste0(meta$id, ".txt"))
  exp_file <- file.path("testing/expected", paste0(meta$id, ".txt"))
  # null graphics device: some console cases draw base plots as scaffolding
  png(tempfile(fileext = ".png"))
  con <- file(out_file, "w")
  sink(con)
  err <- NULL
  tryCatch(source(file, local = new.env(), echo = FALSE, print.eval = TRUE),
           error = function(e) err <<- conditionMessage(e))
  sink()
  close(con)
  dev.off()
  if (!is.null(err)) {
    return(list(status = "FAIL", msg = paste("uncaught error (use try_show):", err)))
  }
  if (update_expected) {
    file.copy(out_file, exp_file, overwrite = TRUE)
    return(list(status = "UPDATED", msg = basename(exp_file)))
  }
  if (!file.exists(exp_file)) {
    return(list(status = "NEW",
                msg = sprintf("review %s, then snapshot: Rscript testing/run.R --update %s",
                              out_file, meta$id)))
  }
  got  <- trimws(readLines(out_file, warn = FALSE), "right")
  want <- trimws(readLines(exp_file, warn = FALSE), "right")
  if (identical(got, want)) return(list(status = "OK", msg = basename(out_file)))
  n <- max(length(got), length(want))
  first <- which(!mapply(identical, got[seq_len(n)], want[seq_len(n)]))[1]
  list(status = "FAIL",
       msg = sprintf("output differs from expected at line %d:\n      expected: %s\n      got:      %s",
                     first,
                     ifelse(first <= length(want), want[first], "<nothing>"),
                     ifelse(first <= length(got),  got[first],  "<nothing>")))
}

cat(sprintf("Running %d case(s)...\n\n", length(all_files)))
results <- lapply(all_files, function(f) {
  meta <- parse_case_header(f)
  cat(sprintf("  %-38s [%s] ", meta$id, meta$type))
  res <- if (meta$type == "console") run_console(f, meta) else run_visual(f, meta)
  cat(res$status, "\n")
  if (res$status %in% c("FAIL", "NEW")) cat("      ", res$msg, "\n", sep = "")
  if (res$status == "FAIL" && !is.na(meta$expect)) cat("      EXPECT: ", meta$expect, "\n", sep = "")
  c(res, id = meta$id)
})

statuses <- vapply(results, `[[`, "", "status")
# machine-readable results for report.Rmd's snapshot section
write.csv(data.frame(id = vapply(results, `[[`, "", "id"), status = statuses),
          "testing/output/_results.csv", row.names = FALSE)
cat(sprintf("\n%d/%d OK", sum(statuses == "OK"), length(statuses)))
if (any(statuses == "UPDATED")) cat(sprintf(", %d snapshot(s) updated", sum(statuses == "UPDATED")))
if (any(statuses == "NEW")) cat(sprintf(", %d NEW (no expected snapshot yet)", sum(statuses == "NEW")))
if (any(statuses == "FAIL")) {
  cat(sprintf(", %d FAILED:\n", sum(statuses == "FAIL")))
  for (r in results[statuses == "FAIL"]) cat("  - ", r$id, "\n", sep = "")
} else cat("\n")
cat("\nVisual outputs are in testing/output/ — compare each against testing/reference/<id>.png\n")
