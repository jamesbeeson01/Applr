st <- function(status, fp = "aaa") list(status = status, fingerprint = fp)
ev <- function(type, ...) list(type = type, ...)

test_that("a new output starts Unreviewed", {
  r <- review_transition(NULL, ev("run", fingerprint = "aaa"))
  expect_equal(r$status, "Unreviewed")
})

test_that("an unchanged fingerprint keeps every status", {
  for (s in c("Unreviewed", "Agent approved", "Human approved", "Rejected")) {
    r <- review_transition(st(s), ev("run", fingerprint = "aaa"))
    expect_equal(r$status, s)
    expect_false(r$reset)
  }
})

test_that("a new fingerprint resets every status to Unreviewed", {
  for (s in c("Unreviewed", "Agent approved", "Human approved", "Rejected")) {
    r <- review_transition(st(s), ev("run", fingerprint = "bbb"))
    expect_equal(r$status, "Unreviewed")
    expect_equal(r$fingerprint, "bbb")
    expect_true(r$reset)
  }
})

test_that("agent decisions need an Unreviewed output and a note", {
  expect_equal(review_transition(st("Unreviewed"), ev("agent_approve", note = "ok"))$status, "Agent approved")
  expect_equal(review_transition(st("Unreviewed"), ev("agent_reject", note = "bad"))$status, "Rejected")
  expect_error(review_transition(st("Unreviewed"), ev("agent_approve")), class = "review_transition_error")
  expect_error(review_transition(st("Unreviewed"), ev("agent_approve", note = "  ")), class = "review_transition_error")
  expect_error(review_transition(st("Agent approved"), ev("agent_approve", note = "ok")), class = "review_transition_error")
})

test_that("an agent cannot reach Human approved; a human approves after the agent", {
  expect_error(review_transition(st("Unreviewed"), ev("human_approve")), class = "review_transition_error")
  expect_equal(review_transition(st("Agent approved"), ev("human_approve"))$status, "Human approved")
  expect_equal(review_transition(st("Agent approved"), ev("human_reject", note = "no"))$status, "Rejected")
  expect_error(review_transition(st("Agent approved"), ev("human_reject")), class = "review_transition_error")
})

test_that("a platform variant of Human approved is agent-approvable with a note", {
  expect_equal(review_transition(st("Human approved"), ev("agent_approve_variant", note = "font"))$status, "Human approved")
  expect_error(review_transition(st("Human approved"), ev("agent_approve_variant")), class = "review_transition_error")
  expect_error(review_transition(st("Unreviewed"), ev("agent_approve_variant", note = "x")), class = "review_transition_error")
})

test_that("unknown events are errors", {
  expect_error(review_transition(NULL, ev("nope")), class = "review_transition_error")
})
