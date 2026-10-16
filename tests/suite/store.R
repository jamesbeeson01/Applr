# Review state, case runner and agent commands. Dev-only.
#
# Layout under `root` (default tests/suite):
#   review_state.json         one record per judged output
#   forms/<id>.txt            current serialised form
#   forms/approved/<id>.txt   form at the last approval, for diffs
# Rendered PNGs go to `png_dir` (gitignored) and are for viewing only.

suite_paths <- function(root = "tests/suite", png_dir = "tests/output") {
  list(state = file.path(root, "review_state.json"),
       forms = file.path(root, "forms"),
       approved = file.path(root, "forms", "approved"),
       png = png_dir)
}

file_id <- function(id) gsub("/", "__", id, fixed = TRUE)

read_state <- function(paths) {
  if (!file.exists(paths$state)) return(list())
  jsonlite::read_json(paths$state)
}

write_state <- function(state, paths) {
  dir.create(dirname(paths$state), showWarnings = FALSE, recursive = TRUE)
  state <- state[order(names(state))]
  jsonlite::write_json(state, paths$state, pretty = TRUE, auto_unbox = TRUE)
}

write_form <- function(dir, id, form) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  writeLines(form, file.path(dir, paste0(file_id(id), ".txt")), useBytes = TRUE)
}

save_png <- function(plot, id, paths) {
  dir.create(paths$png, showWarnings = FALSE, recursive = TRUE)
  grDevices::png(file.path(paths$png, paste0(file_id(id), ".png")),
                 width = 800, height = 600, res = 100)
  on.exit(grDevices::dev.off())
  print(plot)
}

# Runs one case file under testthat. Returns whether every expectation
# passed, plus the judged outputs it declared.
run_case_file <- function(file) {
  registry <- new.env()
  case <- sub("^test-case_?", "", sub("\\.R$", "", basename(file)))
  old <- options(applr.judged_registry = registry, applr.judged_case = case)
  on.exit(options(old))
  res <- testthat::test_file(file, reporter = "silent", stop_on_failure = FALSE)
  df <- as.data.frame(res)
  list(case = case,
       passed = nrow(df) > 0 && !any(df$failed > 0 | df$error),
       outputs = as.list(registry))
}

now_stamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")

# Runs every case file in `dir`. A case whose expectations fail leaves the
# review state untouched.
run_suite <- function(dir = "tests/testthat", paths = suite_paths(), pattern = "^test-case_.*\\.R$") {
  report <- list()
  for (file in list.files(dir, pattern = pattern, full.names = TRUE)) {
    r <- run_case_file(file)
    if (!r$passed) {
      report[[r$case]] <- "FAIL (expectations; review state untouched)"
      next
    }
    # Fingerprint the whole case before touching state, then write it, so an
    # error in one case never loses or half-applies another's results.
    fps <- tryCatch(lapply(r$outputs, fingerprint_static_plot),
                    error = function(e) e)
    if (inherits(fps, "error")) {
      report[[r$case]] <- paste("ERROR fingerprinting:", conditionMessage(fps))
      next
    }
    state <- read_state(paths)
    for (id in names(fps)) {
      fp <- fps[[id]]
      old <- state[[id]]
      tr <- review_transition(
        if (is.null(old)) NULL else list(status = old$status, fingerprint = old$fingerprint),
        list(type = "run", fingerprint = fp$fingerprint)
      )
      rec <- old %||% list()
      if (tr$reset) {
        rec$agent_note <- ""
        rec$rejection_note <- ""
        rec$who <- "runner"
        rec$when <- now_stamp()
        save_png(r$outputs[[id]], id, paths)
      }
      rec$fingerprint <- tr$fingerprint
      rec$parts <- fp$part_hashes
      rec$engine_version <- fp$engine_version
      rec$status <- tr$status
      state[[id]] <- rec
      write_form(paths$forms, id, fp$form)
      report[[id]] <- paste0(tr$status, if (tr$reset) " (new fingerprint)" else "")
    }
    write_state(state, paths)
  }
  invisible(report)
}

list_unreviewed <- function(paths = suite_paths()) {
  state <- read_state(paths)
  names(Filter(function(r) identical(r$status, "Unreviewed"), state))
}

# Text diff of the current form against the last approved one.
diff_output <- function(id, paths = suite_paths()) {
  now <- file.path(paths$forms, paste0(file_id(id), ".txt"))
  before <- file.path(paths$approved, paste0(file_id(id), ".txt"))
  if (!file.exists(now)) stop("No such judged output: ", id, call. = FALSE)
  if (!file.exists(before)) return(c("(no approved version yet)", readLines(now)))
  out <- suppressWarnings(system2("git", c("diff", "--no-index", "--no-color", "--",
                                           shQuote(before), shQuote(now)),
                                  stdout = TRUE, stderr = TRUE))
  if (length(out) == 0) "(identical to last approved version)" else out
}

# Agent decision. Only the agent events exist here; Human approved is never
# written by this code path.
agent_decide <- function(id, decision = c("approve", "reject"), note, paths = suite_paths()) {
  decision <- match.arg(decision)
  state <- read_state(paths)
  rec <- state[[id]]
  if (is.null(rec)) stop("No such judged output: ", id, call. = FALSE)
  tr <- review_transition(list(status = rec$status, fingerprint = rec$fingerprint),
                          list(type = paste0("agent_", decision), note = note))
  rec$status <- tr$status
  rec$who <- "agent"
  rec$when <- now_stamp()
  if (decision == "approve") {
    rec$agent_note <- note
    rec$rejection_note <- ""
    write_form(paths$approved, id,
               readLines(file.path(paths$forms, paste0(file_id(id), ".txt")), warn = FALSE))
  } else {
    rec$rejection_note <- note
    rec$agent_note <- ""
  }
  state[[id]] <- rec
  write_state(state, paths)
  invisible(rec)
}
