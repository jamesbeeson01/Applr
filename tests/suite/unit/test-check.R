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
