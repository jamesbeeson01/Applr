# The trust tests from the spec's "Trusting a fingerprint", written once
# against the output-type contract. A type gets them by registering a demo
# case and a list of mutations; see test-contract.R and test-fake-type.R.

# The outputs of `type` that a case file declares, as judged_output() entries.
type_entries <- function(type, case_file) {
  r <- run_case_file(case_file)
  stopifnot(r$passed)
  Filter(function(e) identical(resolve_output_type(e)$name, type), r$outputs)
}

demo_entries <- function(type) {
  demo <- output_type(type)$demo
  if (is.null(demo)) stop("Output type '", type, "' names no demo case.")
  type_entries(type, case_path(demo))
}

fingerprint_of <- function(entry) serialise_output(entry)$fingerprint

mutate_entry <- function(entry, mutation) {
  x <- mutation(list(object = entry$object, states = entry$states))
  entry$object <- x$object
  entry["states"] <- list(x$states)
  entry
}

reregister <- function(t) do.call(register_output_type, t)

# Re-registers `type` for the rest of the calling test with serialise() tagging
# each view with its own fingerprint, and render() and live() logging the tag
# they were handed and the output folder they wrote to.
probe_type <- function(type, log, env = parent.frame()) {
  t <- output_type(type)
  original <- t
  t$serialise <- function(object, states) {
    s <- original$serialise(object, states)
    attr(s$view, "probe") <- fingerprint_output(list(parts = lapply(s$parts, normalise_common)))$fingerprint
    s
  }
  note <- function(view, file, what) {
    log$calls[[length(log$calls) + 1]] <- list(
      id = basename(dirname(file)), what = what, probe = attr(view, "probe") %||% "(none)")
  }
  if (!is.null(t$live)) t$live <- function(view, file) { note(view, file, "live"); original$live(view, file) }
  t$render <- function(view, state, file, live) {
    note(view, file, basename(file))
    original$render(view, state, file, live)
  }
  reregister(t)
  withr::defer(reregister(original), envir = env)
}

# Completeness by construction: every view is drawn from the build that was
# hashed for that same output, and what is stored is exactly what is hashed.
# `entries` must hold at least two outputs with different fingerprints, so a
# view drawn from the wrong one shows.
expect_complete <- function(type, entries) {
  fps <- vapply(entries, fingerprint_of, "")
  expect_gt(length(unique(fps)), 1)

  log <- new.env()
  log$calls <- list()
  probe_type(type, log)
  paths <- temp_paths()
  apply_case(list(case = "c", passed = TRUE, outputs = entries), paths)
  state <- read_state(paths)

  for (id in names(entries)) {
    rec <- state[[id]]
    calls <- Filter(function(cl) cl$id == file_id(id), log$calls)
    n_states <- length(serialise_output(entries[[id]])$states)
    expect_equal(sum(vapply(calls, function(cl) cl$what != "live", TRUE)), n_states)
    for (cl in calls) expect_identical(cl$probe, rec$fingerprint, label = paste(id, cl$what, "view tag"))

    form <- readLines(file.path(paths$forms, paste0(file_id(id), ".txt")), warn = FALSE)
    expect_equal(rec$fingerprint, hash_text(paste(form, collapse = "\n")))
    expect_equal(form, strsplit(serialise_output(entries[[id]])$form, "\n")[[1]])
    expect_equal(names(rec$parts), names(serialise_output(entries[[id]])$part_hashes))
  }
}

# Sensitivity: each of the type's mutations changes the fingerprint.
expect_sensitive <- function(type, entry) {
  mutations <- output_type(type)$mutations
  expect_gt(length(mutations), 0)
  base <- fingerprint_of(entry)
  for (m in names(mutations)) {
    expect_false(base == fingerprint_of(mutate_entry(entry, mutations[[m]])),
                 label = paste0("'", m, "' mutation leaves the fingerprint unchanged; that"))
  }
}

# Stability: two builds in fresh R sessions with different temp folders give
# the fingerprints this session gives. `setup` is R code run after the suite
# loads, for types not registered under types/.
expect_stable <- function(type, case_file, setup = character()) {
  script <- tempfile(fileext = ".R")
  writeLines(c(
    sprintf('setwd("%s")', root),
    'suppressMessages(pkgload::load_all(".", quiet = TRUE))',
    sprintf('source("%s/load.R"); load_suite("%s")', suite_dir, suite_dir),
    setup,
    sprintf('r <- run_case_file("%s")', normalizePath(case_file, winslash = "/")),
    'for (id in sort(names(r$outputs))) {',
    '  s <- serialise_output(r$outputs[[id]])',
    sprintf('  if (s$type$name == "%s") cat("FP:", id, s$fingerprint, "\\n")', type),
    '}'
  ), script)
  build <- function() {
    tmp <- tempfile("tmp")
    dir.create(tmp)
    out <- withr::with_envvar(
      c(TMPDIR = tmp, TMP = tmp, TEMP = tmp),
      suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), script,
                               stdout = TRUE, stderr = TRUE))
    )
    trimws(grep("^FP:", out, value = TRUE))
  }
  here <- type_entries(type, case_file)
  here <- here[sort(names(here))]
  expected <- paste("FP:", names(here), vapply(here, fingerprint_of, ""))
  a <- build()
  b <- build()
  expect_gt(length(a), 0)
  expect_equal(a, b)
  expect_equal(a, expected)
}
