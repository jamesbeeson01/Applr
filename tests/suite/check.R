# Checks a fresh run against the committed review state without writing it,
# for CI (ci.R). Each judged output is compared with the fingerprint recorded
# on the maintainer's machine.

# Runs every case in `dir` and returns one row per judged output: its
# recorded status and fingerprint, the fingerprint here, and which parts
# differ. A case whose expectations fail gives a row with `case_failed`. An
# output the state records but no case produced, or one that fails to
# serialise, stops the run: a missing input must never pass as a match.
check_run <- function(dir = "tests/testthat", paths = suite_paths(), pattern = "^test-case_.*\\.R$") {
  records <- review_records(paths)
  rows <- list()
  outs <- list()
  failed_cases <- character()
  for (file in list.files(dir, pattern = pattern, full.names = TRUE)) {
    r <- run_case_file(file)
    if (!r$passed) failed_cases <- c(failed_cases, r$case)
    for (id in names(r$outputs)) {
      out <- tryCatch(serialise_output(r$outputs[[id]]), error = function(e) {
        stop("Couldn't serialise ", id, ": ", conditionMessage(e), call. = FALSE)
      })
      outs[[id]] <- out
    }
  }
  ran_cases <- unique(sub("/.*", "", names(outs)))
  missing <- setdiff(names(records), names(outs))
  missing <- missing[!sub("/.*", "", missing) %in% failed_cases]
  if (length(missing)) {
    stop("The review state records outputs no case produced: ",
         paste(missing, collapse = ", "), call. = FALSE)
  }
  for (id in names(outs)) {
    out <- outs[[id]]
    rec <- records[[id]]
    recorded_parts <- unlist(rec$parts %||% list())
    here_parts <- unlist(out$part_hashes)
    differ <- names(here_parts)[is.na(recorded_parts[names(here_parts)]) |
                                  recorded_parts[names(here_parts)] != here_parts]
    rows[[id]] <- list(
      id = id, case = sub("/.*", "", id), type = out$type$name,
      status = rec$status %||% "Unreviewed",
      recorded = rec$fingerprint %||% "", fingerprint = out$fingerprint,
      match = identical(rec$fingerprint, out$fingerprint),
      parts_differing = if (identical(rec$fingerprint, out$fingerprint)) character() else differ,
      case_failed = FALSE
    )
  }
  for (case in setdiff(failed_cases, ran_cases)) {
    rows[[case]] <- list(id = case, case = case, type = "", status = "", recorded = "",
                         fingerprint = "", match = FALSE, parts_differing = character(),
                         case_failed = TRUE)
  }
  for (id in names(rows)) if (rows[[id]]$case %in% failed_cases) rows[[id]]$case_failed <- TRUE
  structure(rows, outputs = outs)
}

# Writes the forms and views of every output whose fingerprint differs here,
# so a reviewer can download them. A view that fails to render is noted, not
# fatal: the form alone says what changed.
write_bundle <- function(rows, out_dir) {
  outs <- attr(rows, "outputs")
  paths <- list(views = file.path(out_dir, "views"))
  notes <- list()
  for (row in rows) {
    if (row$match || row$case_failed) next
    out <- outs[[row$id]]
    write_form(file.path(out_dir, "forms"), row$id, out$form)
    err <- tryCatch({ render_views(out, row$id, paths); NULL }, error = function(e) conditionMessage(e))
    if (!is.null(err)) notes[[row$id]] <- paste("views failed:", err)
  }
  notes
}

platform_info <- function() {
  c(utils::capture.output(print(utils::sessionInfo())), "",
    paste("La_library:", La_library()), paste("La_version:", La_version()),
    utils::capture.output(print(extSoftVersion())))
}
