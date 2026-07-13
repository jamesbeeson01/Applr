# run.R — test runner (terminal / AI entry point). Run from the package root:
#
#   Rscript testing/run.R                  # run every case in testing/cases/
#   Rscript testing/run.R gs_01 err_02     # run specific cases (prefix is enough)
#   Rscript testing/run.R --update gs_02   # re-snapshot expected/ console output for case(s)
#
# Visual cases  -> testing/output/<id>.png   (compare by eye against testing/reference/<id>.png)
#                  PLUS any console output the case emits -> testing/output/<id>.txt,
#                  diffed against testing/expected/<id>.txt. A visual case with no
#                  expected/ snapshot must be silent — unexpected output reports NEW.
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

# diff right-trimmed lines against a snapshot; NULL when identical, else a message
diff_lines <- function(got, want) {
  if (identical(got, want)) return(NULL)
  n <- max(length(got), length(want))
  first <- which(!mapply(identical, got[seq_len(n)], want[seq_len(n)]))[1]
  sprintf("output differs from expected at line %d:\n      expected: %s\n      got:      %s",
          first,
          ifelse(first <= length(want), want[first], "<nothing>"),
          ifelse(first <= length(got),  got[first],  "<nothing>"))
}

read_snapshot <- function(path) trimws(readLines(path, warn = FALSE), "right")

run_visual <- function(file, meta) {
  # clear stale outputs for this case, then draw every plot the case makes
  stale <- list.files("testing/output", sprintf("^%s(-\\d+)?\\.(png|txt)$", meta$id), full.names = TRUE)
  file.remove(stale)
  out_file <- file.path("testing/output",   paste0(meta$id, ".txt"))
  exp_file <- file.path("testing/expected", paste0(meta$id, ".txt"))
  png(file.path("testing/output", paste0(meta$id, "-%02d.png")),
      width = meta$width, height = meta$height, units = "in", res = 300)
  # capture everything the case prints (stdout + messages/warnings); warn = 1
  # makes warnings print immediately, while the sink is still in place
  con <- file(out_file, "w")
  sink(con)
  sink(con, type = "message")
  old_warn <- options(warn = 1)
  err <- NULL
  tryCatch(source(file, local = new.env(), echo = FALSE, print.eval = TRUE),
           error = function(e) err <<- conditionMessage(e))
  options(old_warn)
  sink(type = "message")
  sink()
  close(con)
  dev.off()
  made <- list.files("testing/output", sprintf("^%s-\\d+\\.png$", meta$id), full.names = TRUE)
  if (!is.null(err)) {
    file.remove(c(made, out_file))
    return(list(status = "FAIL", msg = err))
  }
  if (length(made) == 0) {
    file.remove(out_file)
    return(list(status = "FAIL", msg = "case ran but produced no plot"))
  }
  if (length(made) == 1) {
    single <- file.path("testing/output", paste0(meta$id, ".png"))
    file.rename(made, single)
    made <- single
  }

  # console side: whatever the case printed must match its snapshot; a case
  # with no snapshot in expected/ must be silent
  got <- read_snapshot(out_file)
  while (length(got) > 0 && got[length(got)] == "") got <- got[-length(got)]
  silent <- length(got) == 0
  if (silent) file.remove(out_file)
  has_expected <- file.exists(exp_file)
  if (update_expected) {
    if (silent && has_expected) {
      file.remove(exp_file)
      return(list(status = "UPDATED", msg = paste("case is now silent; removed", basename(exp_file))))
    }
    if (!silent) {
      file.copy(out_file, exp_file, overwrite = TRUE)
      return(list(status = "UPDATED", msg = basename(exp_file)))
    }
  }
  if (silent && has_expected) {
    return(list(status = "FAIL",
                msg = sprintf("expected console output (%s) but the case printed nothing",
                              basename(exp_file))))
  }
  if (!silent && !has_expected) {
    return(list(status = "NEW",
                msg = sprintf("case printed console output — review %s, then snapshot: Rscript testing/run.R --update %s",
                              out_file, meta$id)))
  }
  if (!silent) {
    bad <- diff_lines(got, read_snapshot(exp_file))
    if (!is.null(bad)) return(list(status = "FAIL", msg = paste0("console ", bad)))
  }
  list(status = "OK",
       msg = paste(c(basename(made), if (!silent) basename(out_file)), collapse = ", "))
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
  bad <- diff_lines(read_snapshot(out_file), read_snapshot(exp_file))
  if (is.null(bad)) return(list(status = "OK", msg = basename(out_file)))
  list(status = "FAIL", msg = bad)
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
# machine-readable results for report.Rmd (which displays this run's artifacts)
write.csv(data.frame(id     = vapply(results, `[[`, "", "id"),
                     status = statuses,
                     msg    = vapply(results, `[[`, "", "msg")),
          "testing/output/_results.csv", row.names = FALSE)
cat(sprintf("\n%d/%d OK", sum(statuses == "OK"), length(statuses)))
if (any(statuses == "UPDATED")) cat(sprintf(", %d snapshot(s) updated", sum(statuses == "UPDATED")))
if (any(statuses == "NEW")) cat(sprintf(", %d NEW (no expected snapshot yet)", sum(statuses == "NEW")))
if (any(statuses == "FAIL")) {
  cat(sprintf(", %d FAILED:\n", sum(statuses == "FAIL")))
  for (r in results[statuses == "FAIL"]) cat("  - ", r$id, "\n", sep = "")
} else cat("\n")
cat("\nVisual outputs are in testing/output/ — compare each against testing/reference/<id>.png\n")
