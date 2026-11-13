# check_run() compares a fresh run with the review state without writing it.

test_that("a recorded fingerprint matches; a changed output reports which parts differ", {
  paths <- temp_paths()
  run_suite(case_copy(), paths)
  before <- read_state(paths)
  rows <- check_run(case_copy(), paths)
  expect_true(rows[[id]]$match)
  expect_identical(read_state(paths), before)

  rows <- check_run(renamed(), paths)
  expect_false(rows[[id]]$match)
  expect_equal(rows[[id]]$parts_differing, "main")
  expect_identical(read_state(paths), before)
})

test_that("an output the state records but no case produced stops the check", {
  paths <- temp_paths()
  run_suite(case_copy(), paths)
  empty <- tempfile("case")
  dir.create(empty)
  file.copy(file.path(case_dir, "helper-judged.R"), empty)
  expect_error(check_run(empty, paths), "no case produced: single_predictor_line/plot")
})

test_that("an output that fails to serialise stops the check", {
  paths <- temp_paths()
  dir <- case_copy(extra = 'judged_output("broken", 1, type = "static_plot")')
  expect_error(check_run(dir, paths), "Couldn't serialise single_predictor_line/broken")
})

test_that("a case whose expectations fail is reported with the failing expectation", {
  paths <- temp_paths()
  dir <- case_copy(extra = 'test_that("fails", expect_equal(1, 2))')
  rows <- check_run(dir, paths)
  expect_true(rows[[id]]$case_failed)
  expect_match(attr(rows, "failures")$single_predictor_line, "^fails: ")
})

test_that("CI shows each review status by the approved policy", {
  expect_equal(ci_verdict("Human approved"), "pass")
  expect_equal(ci_verdict("Human approved (platform variant)"), "pass")
  expect_equal(ci_verdict("Agent approved"), "warn")
  expect_equal(ci_verdict("Unreviewed"), "fail")
  expect_equal(ci_verdict("Unreviewed (platform variant)"), "fail")
  expect_equal(ci_verdict("Rejected"), "fail")
  expect_equal(ci_verdict("Human approved", case_failed = TRUE), "fail")
})

test_that("the release check accepts Human approved and its platform variants only", {
  expect_equal(release_verdict("Human approved"), "pass")
  expect_equal(release_verdict("Human approved (platform variant)"), "pass")
  for (s in c("Agent approved", "Unreviewed", "Unreviewed (platform variant)", "Rejected")) {
    expect_equal(release_verdict(s), "fail", label = s)
  }
  expect_equal(release_verdict("Human approved", case_failed = TRUE), "fail")
})

test_that("a variant counts only for its platform, fingerprint and a Human approved original", {
  v <- list(fingerprint = "bbb", of = "aaa")
  rec <- list(status = "Human approved", fingerprint = "aaa", variants = list(ubuntu = v))
  expect_equal(platform_status(NULL, "aaa", "ubuntu"), "Unreviewed")
  expect_equal(platform_status(rec, "aaa", "ubuntu"), "Human approved")
  expect_equal(platform_status(rec, "bbb", "ubuntu"), "Human approved (platform variant)")
  expect_equal(platform_status(rec, "bbb", "macos"), "Unreviewed (platform variant)")
  expect_equal(platform_status(rec, "ccc", "ubuntu"), "Unreviewed (platform variant)")
  changed <- modifyList(rec, list(fingerprint = "ddd"))
  expect_equal(platform_status(changed, "bbb", "ubuntu"), "Unreviewed (platform variant)")
  agent <- modifyList(rec, list(status = "Agent approved"))
  expect_equal(platform_status(agent, "bbb", "ubuntu"), "Unreviewed (platform variant)")
})

# A reviewed demo output, with a CI bundle reporting a variant of it.
approved_with_bundle <- function(human = TRUE) {
  paths <- temp_paths()
  run_suite(case_copy(), paths)
  agent_decide(id, "approve", "Line follows the points.", paths)
  if (human) human_decide(id, "approve", "", read_state(paths)[[id]]$fingerprint, paths)
  bundle <- tempfile("bundle")
  dir.create(bundle)
  jsonlite::write_json(list(platform_name = "gha-ubuntu", outputs = list(list(
    id = id, match = FALSE, recorded = read_state(paths)[[id]]$fingerprint,
    fingerprint = "bbbbbbbbbbbb", parts_differing = list("main")))),
    file.path(bundle, "report.json"), auto_unbox = TRUE)
  list(paths = paths, bundle = bundle)
}

test_that("an agent approves a platform variant from a bundle, with a note", {
  x <- approved_with_bundle()
  expect_error(agent_approve_variant(x$bundle, id, "", x$paths), "requires a note")
  agent_approve_variant(x$bundle, id, "Tick labels one pixel lower.", x$paths)
  rec <- review_records(x$paths)[[id]]
  expect_equal(rec$variants$`gha-ubuntu`$of, rec$fingerprint)
  expect_equal(platform_status(rec, "bbbbbbbbbbbb", "gha-ubuntu"), "Human approved (platform variant)")
  expect_equal(rec$status, "Human approved")
})

test_that("a variant of an output that isn't Human approved, or a stale bundle, is refused", {
  x <- approved_with_bundle(human = FALSE)
  expect_error(agent_approve_variant(x$bundle, id, "note", x$paths), "needs status Human approved")
  x <- approved_with_bundle()
  run_suite(renamed(), x$paths)
  expect_error(agent_approve_variant(x$bundle, id, "note", x$paths), "older fingerprint")
})

test_that("the release audit compares fresh views with those kept at approval", {
  x <- approved_with_bundle(human = FALSE)
  rows <- check_run(case_copy(), x$paths)
  expect_equal(release_audit(rows, x$paths)[[id]], "no approved view")

  x <- approved_with_bundle()
  rows <- check_run(case_copy(), x$paths)
  expect_equal(release_audit(rows, x$paths)[[id]], "same")

  kept <- file.path(view_dir(id, x$paths, approved = TRUE), "plot.png")
  png_view(kept, function() plot(1))
  expect_equal(release_audit(rows, x$paths)[[id]], "changed: plot")
})
