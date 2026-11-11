# Human decisions live in their own file, written only by human_decide()
# (the review server). Review status is derived from both files
# (spec: "Review state storage").

agent_approved <- function() {
  paths <- temp_paths()
  dir <- case_copy()
  run_suite(dir, paths)
  agent_decide(id, "approve", "Line follows the points.", paths)
  list(paths = paths, dir = dir, fp = read_state(paths)[[id]]$fingerprint)
}

test_that("a human approval of the current fingerprint makes it Human approved, in the decisions file only", {
  s <- agent_approved()
  human_decide(id, "approve", "", s$fp, s$paths)
  expect_equal(review_records(s$paths)[[id]]$status, "Human approved")
  expect_equal(review_records(s$paths)[[id]]$who, "human")
  expect_equal(read_state(s$paths)[[id]]$status, "Agent approved")
  d <- read_decisions(s$paths)
  expect_length(d, 1)
  expect_equal(d[[1]][c("id", "fingerprint", "decision")], list(id = id, fingerprint = s$fp, decision = "approve"))

  run_suite(s$dir, s$paths)
  expect_equal(review_records(s$paths)[[id]]$status, "Human approved")
  expect_equal(review_page_data(s$paths)[[id]]$status, "Human approved")
})

test_that("a human decision for an old fingerprint has no effect", {
  s <- agent_approved()
  human_decide(id, "approve", "", s$fp, s$paths)
  run_suite(renamed(), s$paths)
  expect_equal(review_records(s$paths)[[id]]$status, "Unreviewed")
  expect_equal(list_unreviewed(s$paths), id)
  expect_length(read_decisions(s$paths), 1)
})

test_that("a human rejection needs a note, sets Rejected and holds against the agent", {
  s <- agent_approved()
  expect_error(human_decide(id, "reject", " ", s$fp, s$paths), class = "review_transition_error")
  expect_false(file.exists(s$paths$decisions))

  human_decide(id, "reject", "Title clipped.", s$fp, s$paths)
  rec <- review_records(s$paths)[[id]]
  expect_equal(c(rec$status, rec$rejection_note, rec$who), c("Rejected", "Title clipped.", "human"))
  expect_error(human_decide(id, "approve", "", s$fp, s$paths), class = "review_transition_error")
  expect_error(agent_decide(id, "approve", "fine", s$paths), class = "review_transition_error")
  expect_length(read_decisions(s$paths), 1)
})

test_that("the human can't decide on an output no agent has approved, or on a stale page", {
  paths <- temp_paths()
  run_suite(case_copy(), paths)
  fp <- read_state(paths)[[id]]$fingerprint
  expect_error(human_decide(id, "approve", "", fp, paths), class = "review_transition_error")
  agent_decide(id, "approve", "ok", paths)
  expect_error(human_decide(id, "approve", "", "000000000000", paths), class = "review_stale_error")
  expect_false(file.exists(paths$decisions))
})

test_that("a human approval keeps that version's form and views for comparison", {
  s <- agent_approved()
  approved_view <- file.path(s$paths$views, "approved", "single_predictor_line__plot", "plot.png")
  approved_form <- file.path(s$paths$approved, "single_predictor_line__plot.txt")
  expect_false(file.exists(approved_view))
  human_decide(id, "approve", "", s$fp, s$paths)
  expect_true(file.exists(approved_view))
  expect_equal(readLines(approved_form), readLines(file.path(s$paths$forms, "single_predictor_line__plot.txt")))

  run_suite(renamed(), s$paths)
  d <- diff_output(id, s$paths)
  expect_true(any(grepl("^-.*Single predictor", d)) && any(grepl("^\\+.*Renamed", d)))
  expect_false(is.na(review_page_data(s$paths)[[id]]$states$approved_file))
})

test_that("no agent command writes the decisions file", {
  paths <- temp_paths()
  dir <- case_copy()
  run_suite(dir, paths)
  list_unreviewed(paths)
  diff_output(id, paths)
  agent_decide(id, "reject", "Needs a subtitle.", paths)
  run_suite(renamed(), paths)
  agent_decide(id, "approve", "Renamed as asked.", paths)
  expect_false(file.exists(paths$decisions))
})
