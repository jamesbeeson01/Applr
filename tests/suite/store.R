# Review state, case runner and agent commands. Dev-only.
#
# Layout under `root` (default tests/suite):
#   review_state.json         one record per judged output
#   forms/<id>.txt            current serialised form
#   forms/approved/<id>.txt   form at the last approval, for diffs
# Views go to `view_dir` (gitignored) and are for viewing only:
#   <id>/<state>.<ext>, <id>/live.html, approved/<id>/, lib/

suite_paths <- function(root = "tests/suite", view_dir = "tests/output") {
  list(state = file.path(root, "review_state.json"),
       forms = file.path(root, "forms"),
       approved = file.path(root, "forms", "approved"),
       views = view_dir)
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

# Runs every case file in `dir` and applies each to the review state.
run_suite <- function(dir = "tests/testthat", paths = suite_paths(), pattern = "^test-case_.*\\.R$") {
  report <- list()
  for (file in list.files(dir, pattern = pattern, full.names = TRUE)) {
    report <- c(report, apply_case(run_case_file(file), paths))
  }
  invisible(report)
}

# Applies one run case to the review state. A case whose expectations fail
# leaves it untouched. Views are rendered only for Unreviewed outputs, when
# their fingerprint is new or their views are missing.
apply_case <- function(r, paths) {
  if (!r$passed) {
    return(stats::setNames(list("FAIL (expectations; review state untouched)"), r$case))
  }
  # Serialise the whole case before touching state, then write it, so an
  # error in one case never loses or half-applies another's results.
  outs <- tryCatch(lapply(r$outputs, serialise_output), error = function(e) e)
  if (inherits(outs, "error")) {
    return(stats::setNames(list(paste("ERROR serialising:", conditionMessage(outs))), r$case))
  }
  report <- list()
  state <- read_state(paths)
  for (id in names(outs)) {
    out <- outs[[id]]
    old <- state[[id]]
    tr <- review_transition(
      if (is.null(old)) NULL else list(status = old$status, fingerprint = old$fingerprint),
      list(type = "run", fingerprint = out$fingerprint)
    )
    rec <- old %||% list()
    if (tr$reset) {
      rec$agent_note <- ""
      rec$rejection_note <- ""
      rec$who <- "runner"
      rec$when <- now_stamp()
    }
    rec$case <- r$case
    rec$type <- out$type$name
    rec$view <- out$type$view
    rec$states <- names(out$states)
    rec$fingerprint <- tr$fingerprint
    rec$parts <- out$part_hashes
    rec$engine_version <- out$engine_version
    rec$status <- tr$status
    state[[id]] <- rec
    write_form(paths$forms, id, out$form)
    note <- if (tr$reset) " (new fingerprint)" else ""
    if (tr$status == "Unreviewed" && (tr$reset || !views_present(out, id, paths))) {
      err <- tryCatch({ render_views(out, id, paths); NULL }, error = function(e) e)
      if (!is.null(err)) note <- paste0(note, "; views failed: ", conditionMessage(err))
    }
    report[[id]] <- paste0(tr$status, note)
  }
  write_state(state, paths)
  report
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
    keep_approved_views(id, paths)
  } else {
    rec$rejection_note <- note
    rec$agent_note <- ""
  }
  state[[id]] <- rec
  write_state(state, paths)
  invisible(rec)
}

# Copies an output's current views to approved/, for the review page's
# comparison against the last approved render.
keep_approved_views <- function(id, paths) {
  from <- view_dir(id, paths)
  to <- view_dir(id, paths, approved = TRUE)
  unlink(to, recursive = TRUE)
  if (!dir.exists(from)) return(invisible())
  dir.create(to, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(from, full.names = TRUE), to, recursive = TRUE)
  invisible(to)
}

# What the review page shows for each output, from the review state alone.
review_page_data <- function(paths = suite_paths()) {
  state <- read_state(paths)
  lapply(stats::setNames(names(state), names(state)), function(id) {
    rec <- state[[id]]
    ext <- if (is.null(rec$type)) "png" else output_type(rec$type)$format
    files <- function(approved) {
      f <- file.path(view_dir(id, paths, approved), paste0(unlist(rec$states), ".", ext))
      ifelse(file.exists(f), f, NA_character_)
    }
    live <- file.path(view_dir(id, paths), "live.html")
    list(
      id = id, case = rec$case, type = rec$type, view = rec$view,
      status = rec$status, who = rec$who, when = rec$when,
      agent_note = rec$agent_note, rejection_note = rec$rejection_note,
      fingerprint = rec$fingerprint, parts = names(rec$parts),
      states = data.frame(name = unlist(rec$states), file = files(FALSE),
                          approved_file = files(TRUE)),
      live = if (file.exists(live)) live else NA_character_,
      form = file.path(paths$forms, paste0(file_id(id), ".txt")),
      approved_form = file.path(paths$approved, paste0(file_id(id), ".txt"))
    )
  })
}
