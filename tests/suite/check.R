# Checks a fresh run against the committed review state without writing it:
# the CI check (ci.R) and the release check (release.R). Fingerprints
# recorded on the maintainer's machine are authoritative on every platform
# (spec: "CI"); one that differs elsewhere is a platform variant.

# The platform name variants are recorded under. CI sets it per runner.
ci_platform <- function() {
  p <- Sys.getenv("APPLR_SUITE_PLATFORM")
  if (nzchar(p)) p else paste(tolower(Sys.info()[["sysname"]]), R.version$arch, sep = "-")
}

# An output's review status on `platform`, given its fingerprint there. A
# variant counts only while the original it was approved against is still
# the recorded, Human approved fingerprint.
platform_status <- function(rec, fingerprint, platform) {
  if (is.null(rec)) return("Unreviewed")
  if (identical(rec$fingerprint, fingerprint)) return(rec$status)
  v <- rec$variants[[platform]]
  if (!is.null(v) && identical(v$fingerprint, fingerprint) && identical(v$of, rec$fingerprint) &&
      identical(rec$status, "Human approved")) {
    return("Human approved (platform variant)")
  }
  "Unreviewed (platform variant)"
}

# How a status shows on CI: "pass", "warn" or "fail".
ci_verdict <- function(status, case_failed = FALSE) {
  if (case_failed) return("fail")
  if (startsWith(status, "Human approved")) return("pass")
  if (identical(status, "Agent approved")) return("warn")
  "fail"
}

# The release check accepts Human approved only, a platform variant of it
# included.
release_verdict <- function(status, case_failed = FALSE) {
  if (!case_failed && startsWith(status, "Human approved")) "pass" else "fail"
}

# Runs every case in `dir` and returns one row per judged output: its
# recorded status and fingerprint, the fingerprint and status here, and which
# parts differ. A case whose expectations fail gives a row with
# `case_failed`. An output the state records but no case produced, or one
# that fails to serialise, stops the run: a missing input must never pass as
# a match.
check_run <- function(dir = "tests/testthat", paths = suite_paths(), platform = ci_platform(),
                      pattern = "^test-case_.*\\.R$") {
  records <- review_records(paths)
  rows <- list()
  outs <- list()
  failed_cases <- character()
  failures <- list()
  for (file in list.files(dir, pattern = pattern, full.names = TRUE)) {
    r <- run_case_file(file)
    if (!r$passed) {
      failed_cases <- c(failed_cases, r$case)
      failures[[r$case]] <- r$failures
    }
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
    match <- identical(rec$fingerprint, out$fingerprint)
    differ <- names(here_parts)[is.na(recorded_parts[names(here_parts)]) |
                                  recorded_parts[names(here_parts)] != here_parts]
    rows[[id]] <- list(
      id = id, case = sub("/.*", "", id), type = out$type$name,
      status = rec$status %||% "Unreviewed",
      status_here = platform_status(rec, out$fingerprint, platform),
      recorded = rec$fingerprint %||% "", fingerprint = out$fingerprint,
      match = match, parts_differing = if (match) character() else differ,
      case_failed = FALSE
    )
  }
  for (case in setdiff(failed_cases, ran_cases)) {
    rows[[case]] <- list(id = case, case = case, type = "", status = "", status_here = "",
                         recorded = "", fingerprint = "", match = FALSE,
                         parts_differing = character(), case_failed = TRUE)
  }
  for (id in names(rows)) if (rows[[id]]$case %in% failed_cases) rows[[id]]$case_failed <- TRUE
  structure(rows, outputs = outs, failures = failures, platform = platform)
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

# Agent approval of a platform variant, from the bundle a CI run uploaded
# (its report.json). The note says what differs. Refused unless the original
# is Human approved and the bundle was checked against its current
# fingerprint.
agent_approve_variant <- function(bundle, id, note, paths = suite_paths()) {
  report <- jsonlite::read_json(file.path(bundle, "report.json"))
  row <- Filter(function(r) identical(r$id, id), report$outputs)
  if (!length(row) || isTRUE(row[[1]]$match)) {
    stop("The bundle has no platform variant of ", id, call. = FALSE)
  }
  row <- row[[1]]
  rec <- review_records(paths)[[id]]
  if (is.null(rec)) stop("No such judged output: ", id, call. = FALSE)
  if (!identical(row$recorded, rec$fingerprint)) {
    stop("The bundle was checked against an older fingerprint of ", id,
         "; run CI again.", call. = FALSE)
  }
  review_transition(list(status = rec$status, fingerprint = rec$fingerprint),
                    list(type = "agent_approve_variant", note = note))
  state <- read_state(paths)
  state[[id]]$variants[[report$platform_name]] <- list(
    fingerprint = row$fingerprint, of = rec$fingerprint,
    parts_differing = row$parts_differing, note = note, who = "agent", when = now_stamp())
  write_state(state, paths)
  invisible(state[[id]])
}

# The release audit (spec: "Trusting a fingerprint", rule 4): every state is
# rendered again and compared with the view kept at its human approval on
# this machine. Returns, per output, "same", "no approved view" or the
# states that changed. A changed view under an unchanged fingerprint means
# an input is missing from the serialised form: a suite bug.
release_audit <- function(rows, paths = suite_paths()) {
  outs <- attr(rows, "outputs")
  fresh <- list(views = tempfile("audit"))
  on.exit(unlink(fresh$views, recursive = TRUE))
  Map(function(id, out) {
    files <- paste0(names(out$states), ".", out$type$format)
    kept <- file.path(view_dir(id, paths, approved = TRUE), files)
    if (!all(file.exists(kept))) return("no approved view")
    render_views(out, id, fresh)
    now <- file.path(view_dir(id, fresh), files)
    changed <- names(out$states)[!mapply(same_view, kept, now)]
    if (length(changed)) paste("changed:", paste(changed, collapse = ", ")) else "same"
  }, names(outs), outs)
}

# PNGs are compared pixel for pixel; other views byte for byte.
same_view <- function(a, b) {
  if (!file.exists(b)) return(FALSE)
  if (grepl("\\.png$", a)) return(identical(png::readPNG(a), png::readPNG(b)))
  identical(readBin(a, "raw", file.size(a)), readBin(b, "raw", file.size(b)))
}

platform_info <- function() {
  c(utils::capture.output(print(utils::sessionInfo())), "",
    paste("La_library:", La_library()), paste("La_version:", La_version()),
    utils::capture.output(print(extSoftVersion())))
}
