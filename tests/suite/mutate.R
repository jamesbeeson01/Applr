# Mutation check: tests the suite's own unit tests. Each break below is
# applied, one at a time, to a fresh copy of tests/suite; the copy's unit
# tests then run, and the break counts as caught when any test fails. An
# unbroken copy must pass first. Run from the package root:
#   Rscript tests/suite/mutate.R [workers] [--full]
# By default a broken copy stops at its first failing test, which is all a
# verdict needs. --full runs every test, so the report lists every test that
# catches each break. The unbroken copy always runs in full, and if it fails,
# the run stops there.
# Writes tests/suite/mutation_report.json, which the review page shows. Its
# `code` is suite_code_hash() (stamp.R), so the page can tell when the suite
# has changed since and the check is due again.
# Every break must be caught; one that isn't needs a new test.

source("tests/suite/stamp.R")

# `line` is a fixed substring naming exactly one line of `file` (or the
# `nth` line containing it); that whole line becomes `to`.
breaks <- list(
  list(name = "A changed fingerprint keeps its status",
       file = "status.R", line = "!identical(state$fingerprint, event$fingerprint)",
       to = "      if (is.null(state)) {"),
  list(name = "A part is dropped from the serialised form (core)",
       file = "fingerprint.R", line = "parts <- serialised$parts",
       to = "  parts <- utils::head(serialised$parts, max(1, length(serialised$parts) - 1))"),
  list(name = "A part is dropped from the serialised form (plotly_3d presets)",
       file = "types/plotly_3d.R", line = "presets = canonical_json(states),", to = ""),
  list(name = "Negative-zero normalisation is skipped",
       file = "fingerprint.R", line = "(?<![A-Za-z0-9_.])", to = "  lines"),
  list(name = "An agent's approval with no note is accepted",
       file = "status.R", line = "agent_approve = { need_note();",
       to = "    agent_approve = { need_status(\"Unreviewed\"); keep(\"Agent approved\") },"),
  list(name = "An agent's rejection with no note is accepted",
       file = "status.R", line = "agent_reject = { need_note();",
       to = "    agent_reject = { need_status(\"Unreviewed\"); keep(\"Rejected\") },"),
  list(name = "An agent writes Human approved",
       file = "store.R", line = "rec$who <- \"agent\"",
       to = "  rec$who <- \"agent\"; if (decision == \"approve\") rec$status <- \"Human approved\""),
  list(name = "A view is rendered from another output than the one hashed",
       file = "store.R", line = "render_views(out, id, paths)",
       to = "      err <- tryCatch({ render_views(outs[[1]], id, paths); NULL }, error = function(e) e)"),
  list(name = "A view is rendered from the declared object, not the hashed build",
       file = "store.R", line = "render_views(out, id, paths)",
       to = paste("      err <- tryCatch({ o <- out; o$view <- r$outputs[[id]]$object;",
                  "render_views(o, id, paths); NULL }, error = function(e) e)")),
  list(name = "Views are rendered for outputs that are not Unreviewed",
       file = "store.R", line = "tr$status == \"Unreviewed\" && (tr$reset",
       to = "    if (tr$reset || !views_present(out, id, paths)) {"),
  list(name = "Approved views are not kept for comparison",
       file = "store.R", line = "keep_approved_views(id, paths)", to = ""),
  list(name = "A new fingerprint keeps the old agent note",
       file = "store.R", line = "rec$agent_note <- \"\"", nth = 1, to = ""),
  list(name = "A case whose expectations fail still updates the review state",
       file = "store.R", line = "if (!r$passed) {", to = "  if (FALSE) {"),
  list(name = "A case with no expectations counts as passed",
       file = "store.R", line = "passed = nrow(df) > 0 &&",
       to = "       passed = !any(df$failed > 0 | df$error),"),
  list(name = "A part skips the common normalisation",
       file = "types.R", line = "s$parts <- lapply(s$parts, normalise_common)", to = ""),
  list(name = "Absolute paths are not tokenised",
       file = "fingerprint.R", line = "lines <- gsub(p, token, lines, fixed = TRUE)", to = "      lines"),
  list(name = "Compute steps run without the pinned options",
       file = "fingerprint.R", line = "old <- options(suite_options)", to = "  old <- options()"),
  list(name = "Canonical JSON keeps key order",
       file = "fingerprint.R", line = "x <- x[order(nms, method = \"radix\")]", to = "    NULL"),
  list(name = "Canonical JSON leaves numeric strings unrounded",
       file = "fingerprint.R", line = "x[hit] <- as.character(signif", to = "    NULL"),
  list(name = "Condition text keeps curly quotes",
       file = "types/conditions.R", line = "chartr(", to = "  lines"),
  list(name = "Conditions raised while drawing are missed",
       file = "types/conditions.R", line = "tryCatch(draw_call(call)()",
       to = "    tryCatch(call(), error = function(e) record(\"error\", e)),"),
  list(name = "Returned text drops the names that head each example",
       file = "types/returned_text.R", line = "if (nzchar(labels[i]))",
       to = "    c(if (i > 1) \"\","),
  list(name = "A human decision for an old fingerprint still counts",
       file = "store.R", line = "identical(d$id, id) && identical(d$fingerprint, rec$fingerprint)",
       to = "    mine <- Filter(function(d) identical(d$id, id),"),
  list(name = "Review status ignores human decisions",
       file = "store.R", line = "if (length(mine)) {", to = "    if (FALSE) {"),
  list(name = "An agent command writes the decisions file",
       file = "store.R", line = "write_state(state, paths)", nth = 2,
       to = "  write_state(state, paths); jsonlite::write_json(list(), paths$decisions)"),
  list(name = "A human approval writes Human approved into review_state.json",
       file = "server.R", line = "write_decisions(decisions, paths)",
       to = paste("  write_decisions(decisions, paths); s <- read_state(paths);",
                  "s[[id]]$status <- \"Human approved\"; write_state(s, paths)")),
  list(name = "The server accepts a human rejection without a note",
       file = "server.R", line = "list(type = paste0(\"human_\", decision), note = note))",
       to = "                    list(type = paste0(\"human_\", decision), note = \"-\"))"),
  list(name = "The server accepts a decision on an output no agent has approved",
       file = "server.R", line = "review_transition(list(status = rec$status",
       to = "  review_transition(list(status = \"Agent approved\", fingerprint = rec$fingerprint),"),
  list(name = "The server accepts a decision made on a stale page",
       file = "server.R", line = "if (!identical(fingerprint, rec$fingerprint)) {", to = "  if (FALSE) {"),
  list(name = "A human approval doesn't keep the approved version for comparison",
       file = "server.R", line = "if (decision == \"approve\") keep_approved(id, paths)", to = ""),
  list(name = "The server accepts a decision that isn't JSON",
       file = "server.R", line = "if (!grepl(\"^application/json\", type)) {", to = "  if (FALSE) {"),
  list(name = "The server accepts a decision from another origin",
       file = "server.R", line = "origin != paste0(\"http://\", host)) {", to = "  if (FALSE) {"),
  list(name = "The server serves files outside its folders",
       file = "server.R", line = "if (!startsWith(f, paste0(root, \"/\"))) return(not_found())", to = ""),
  list(name = "An inventory ID used twice is accepted",
       file = "inventory.R", line = "is used more than once", to = "    character()"),
  list(name = "covers() inside a test block is missed",
       file = "inventory.R", line = "for (i in seq_along(args)) {", to = "    for (i in integer()) {"),
  list(name = "The code hash leaves out the cases the unit tests read",
       file = "stamp.R", line = "c(code, cases[file.exists(cases)]", to = "  code"),
  list(name = "CI passes Agent approved without a warning",
       file = "check.R", line = "if (identical(status, \"Agent approved\")) return(\"warn\")",
       to = "  if (identical(status, \"Agent approved\")) return(\"pass\")"),
  list(name = "CI passes an Unreviewed or Rejected output",
       file = "check.R", line = "if (startsWith(status, \"Human approved\")) return(\"pass\")",
       to = "  if (!identical(status, \"Agent approved\")) return(\"pass\")"),
  list(name = "A missing input passes the CI check",
       file = "check.R", line = "if (length(missing)) {", to = "  if (FALSE) {"),
  list(name = "A platform variant still counts after its original changed",
       file = "check.R", line = "identical(v$of, rec$fingerprint) &&",
       to = "  if (!is.null(v) && identical(v$fingerprint, fingerprint) && TRUE &&"),
  list(name = "A platform variant counts for an original that isn't Human approved",
       file = "check.R", line = "identical(rec$status, \"Human approved\")) {", to = "      TRUE) {"),
  list(name = "The release check accepts Agent approved",
       file = "check.R", line = "if (!case_failed && startsWith(status, \"Human approved\"))",
       to = "  if (!case_failed && !identical(status, \"Rejected\")) \"pass\" else \"fail\""),
  list(name = "The release audit misses a changed view",
       file = "check.R", line = "changed <- names(out$states)[!mapply(same_view, kept, now)]",
       to = "    changed <- character()")
)

apply_break <- function(dir, b) {
  path <- file.path(dir, b$file)
  lines <- readLines(path, warn = FALSE)
  hits <- grep(b$line, lines, fixed = TRUE)
  if (is.null(b$nth) && length(hits) != 1) {
    stop("Break '", b$name, "' matches ", length(hits), " lines of ", b$file, "; it must match one.")
  }
  hit <- hits[b$nth %||% 1]
  if (is.na(hit)) stop("Break '", b$name, "' matches no line of ", b$file, ".")
  lines[hit] <- b$to
  writeLines(lines, path)
}

`%||%` <- function(a, b) if (is.null(a)) b else a

suite_copy <- function() {
  dir <- tempfile("suite")
  dir.create(dir)
  file.copy(list.files("tests/suite", full.names = TRUE, all.files = FALSE), dir, recursive = TRUE)
  unlink(file.path(dir, c("mutation_report.json", "test_report.json", "review_state.json",
                         "human_decisions.json", "forms")), recursive = TRUE)
  normalizePath(dir, winslash = "/")
}

# Starts one copy's unit tests in the background; the result lands in out.
# With first = TRUE the copy writes its result and quits at the first failure.
start_tests <- function(dir, out, first = FALSE) {
  script <- file.path(dir, "run_mutation_tests.R")
  write_result <- sprintf('jsonlite::write_json(list(n = n, failed = failed), "%s")', out)
  reporter <- if (!first) '"summary"' else 'testthat::MultiReporter$new(list(testthat::SummaryReporter$new(), FirstFailure$new()))'
  writeLines(c(
    if (first) c(
      'FirstFailure <- R6::R6Class("FirstFailure", inherit = testthat::Reporter, public = list(',
      '  file = NULL, tests = 0,',
      '  start_file = function(name) self$file <- name,',
      '  start_test = function(context, test) self$tests <- self$tests + 1,',
      '  add_result = function(context, test, result) {',
      '    if (!inherits(result, c("expectation_failure", "expectation_error"))) return()',
      '    n <- self$tests; failed <- paste0(self$file, ": ", test)',
      '    cat("\\nStopped at the first failure:", failed, "\\n", conditionMessage(result), "\\n")',
      paste0('    ', write_result),
      '    quit(status = 0)',
      '  }))'
    ),
    sprintf('res <- testthat::test_dir("%s/unit", reporter = %s, stop_on_failure = FALSE)', dir, reporter),
    'df <- as.data.frame(res)',
    'bad <- df[df$failed > 0 | df$error, , drop = FALSE]',
    'n <- nrow(df); failed <- if (nrow(bad)) unique(paste0(bad$file, ": ", bad$test)) else character()',
    write_result
  ), script)
  processx::process$new(file.path(R.home("bin"), "Rscript"), script, stdout = file.path(dir, "log.txt"), stderr = "2>&1",
                        cleanup_tree = TRUE,
                        env = c("current", APPLR_PKG_ROOT = normalizePath(".", winslash = "/")))
}

# Runs every job, `workers` at a time. A failing unbroken copy (job 1) stops
# the rest, since no break can be judged without it.
run_all <- function(jobs, workers, first) {
  results <- vector("list", length(jobs))
  running <- list()
  queue <- seq_along(jobs)
  while (length(queue) || length(running)) {
    while (length(queue) && length(running) < workers) {
      i <- queue[1]
      queue <- queue[-1]
      out <- gsub("\\\\", "/", tempfile(fileext = ".json"))
      running[[as.character(i)]] <- list(i = i, out = out, p = start_tests(jobs[[i]]$dir, out, first = first && i > 1))
    }
    for (k in names(running)) {
      job <- running[[k]]
      if (!job$p$is_alive()) {
        results[[job$i]] <- if (file.exists(job$out)) jsonlite::read_json(job$out, simplifyVector = TRUE)
                            else list(n = 0, failed = character(),
                                      crash = readLines(file.path(jobs[[job$i]]$dir, "log.txt")))
        running[[k]] <- NULL
        cat(sprintf("  done: %s\n", jobs[[job$i]]$name))
        res <- results[[job$i]]
        if (job$i == 1 && (res$n == 0 || length(res$failed))) {
          for (other in running) other$p$kill_tree()
          return(results)
        }
      }
    }
    Sys.sleep(1)
  }
  results
}

# Taken before the run, so edits made while it runs leave the report out of date.
code <- suite_code_hash()

args <- commandArgs(trailingOnly = TRUE)
full <- "--full" %in% args
workers <- as.integer(setdiff(args, "--full")[1])
if (is.na(workers)) workers <- 4

jobs <- c(list(list(name = "(no break)", dir = suite_copy())),
          lapply(breaks, function(b) { d <- suite_copy(); apply_break(d, b); list(name = b$name, dir = d, file = b$file) }))
cat("Running", length(jobs), "copies of the unit tests,", workers, "at a time,",
    if (full) "each in full.\n" else "each broken copy stopping at its first failure (--full runs them all).\n")
results <- run_all(jobs, workers, first = !full)

baseline <- results[[1]]
if (baseline$n == 0 || length(baseline$failed)) {
  cat("The unbroken suite does not pass, so no break can be judged:\n")
  print(baseline)
  cat(readLines(file.path(jobs[[1]]$dir, "log.txt"), warn = FALSE), sep = "\n")
  quit(status = 1)
}

rows <- Map(function(job, res) {
  list(name = job$name, file = job$file, caught = length(res$failed) > 0,
       caught_by = as.list(res$failed), crashed = !is.null(res$crash) && res$n == 0)
}, jobs[-1], results[-1])
report <- list(when = now_stamp(), commit = git_commit(), code = code, tests = baseline$n, full = full,
               caught = sum(vapply(rows, `[[`, TRUE, "caught")), breaks = rows)
jsonlite::write_json(report, "tests/suite/mutation_report.json", pretty = TRUE, auto_unbox = TRUE)

cat(sprintf("\n%d of %d breaks caught (unbroken suite: %d tests pass)\n\n",
            report$caught, length(rows), baseline$n))
for (r in rows) {
  by <- if (r$caught) paste(utils::head(unlist(r$caught_by), 2), collapse = "; ") else "NOT CAUGHT"
  if (r$crashed) by <- "the unit tests crashed: check the break itself"
  cat(sprintf("%-4s %s\n       %s\n", if (r$caught) "ok" else "MISS", r$name, by))
}
if (report$caught < length(rows)) quit(status = 1)
