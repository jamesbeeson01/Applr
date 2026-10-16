renamed <- function() mutated_case_dir('title = "Single predictor"', 'title = "Renamed"')

test_that("running records Unreviewed, unchanged re-runs keep status, changes reset it", {
  paths <- temp_paths()
  dir <- mutated_case_dir()
  run_suite(dir, paths)
  id <- "single_predictor_line/plot"
  expect_equal(read_state(paths)[[id]]$status, "Unreviewed")
  expect_true(file.exists(file.path(paths$png, "single_predictor_line__plot.png")))
  expect_match(read_state(paths)[[id]]$engine_version, "^[0-9.]+$")

  agent_decide(id, "approve", "Line follows the points.", paths)
  expect_equal(read_state(paths)[[id]]$status, "Agent approved")

  run_suite(dir, paths)
  expect_equal(read_state(paths)[[id]]$status, "Agent approved")

  run_suite(renamed(), paths)
  expect_equal(read_state(paths)[[id]]$status, "Unreviewed")
  expect_equal(read_state(paths)[[id]]$agent_note, "")
})

test_that("list and diff work; approval requires a note and rejection stores it", {
  paths <- temp_paths()
  run_suite(mutated_case_dir(), paths)
  id <- "single_predictor_line/plot"
  expect_equal(list_unreviewed(paths), id)
  expect_match(diff_output(id, paths)[1], "no approved version")

  expect_error(agent_decide(id, "approve", "", paths), class = "review_transition_error")
  agent_decide(id, "approve", "ok", paths)
  expect_equal(list_unreviewed(paths), character())

  run_suite(renamed(), paths)
  d <- diff_output(id, paths)
  expect_true(any(grepl("^-.*Single predictor", d)) && any(grepl("^\\+.*Renamed", d)))

  agent_decide(id, "reject", "Title wrong.", paths)
  rec <- read_state(paths)[[id]]
  expect_equal(c(rec$status, rec$rejection_note), c("Rejected", "Title wrong."))
})

test_that("breaking the line fails the expectation and leaves review state untouched", {
  paths <- temp_paths()
  run_suite(mutated_case_dir(), paths)
  before <- read_state(paths)

  broken <- mutated_case_dir("geom_slice(model)", "ggplot2::geom_line(ggplot2::aes(y = 0 * x))")
  report <- run_suite(broken, paths)
  expect_match(report[["single_predictor_line"]], "^FAIL")
  expect_equal(read_state(paths), before)
})

test_that("a case with no expectations does not count as passed", {
  dir <- tempfile("case"); dir.create(dir)
  file.copy(file.path(root, "tests/testthat/helper-judged.R"), dir)
  writeLines("judged_output('plot', ggplot2::ggplot())", file.path(dir, "test-case_empty.R"))
  paths <- temp_paths()
  report <- run_suite(dir, paths)
  expect_match(report[["empty"]], "^FAIL")
  expect_false(file.exists(paths$state))
})

test_that("an error while fingerprinting one case leaves the others' results intact", {
  dir <- mutated_case_dir()
  writeLines(c("judged_output('bad', ggplot2::ggplot() + ggplot2::geom_point(ggplot2::aes(nope)))",
               "test_that('ok', expect_true(TRUE))"),
             file.path(dir, "test-case_zz_bad.R"))
  paths <- temp_paths()
  report <- run_suite(dir, paths)
  expect_match(report[["zz_bad"]], "^ERROR")
  expect_equal(report[["single_predictor_line/plot"]], "Unreviewed (new fingerprint)")
  expect_named(read_state(paths), "single_predictor_line/plot")
})
