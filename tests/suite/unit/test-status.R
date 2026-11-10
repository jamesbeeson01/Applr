# review_transition() against the spec's "Review status rules", one block of
# rows per line of that table, in the same order. `from` is the recorded
# status (NA: never seen); `fp` is the run's fingerprint against a recorded
# "aaa"; `to` is the expected status, or "error".

statuses <- c("Unreviewed", "Agent approved", "Human approved", "Rejected")
row <- function(spec, from, event, to, note = NA, fp = NA) {
  data.frame(spec = spec, from = from, event = event, note = note, fp = fp, to = to)
}

transitions <- rbind(
  # on run: expectations fail -> case fails; review untouched
  #   (not a transition: see "breaking the line fails the expectation" in test-runner.R)
  row("fingerprint == recorded -> keep review status", statuses, "run", statuses, fp = "aaa"),
  row("fingerprint != recorded -> Unreviewed", c(NA, statuses), "run", "Unreviewed", fp = "bbb"),
  row("Unreviewed --agent approve (note required)--> Agent approved", "Unreviewed", "agent_approve", "Agent approved", note = "ok"),
  row("  ...not without a note", "Unreviewed", "agent_approve", "error", note = c(NA, "", "  ")),
  row("  ...not from any other status", c(NA, statuses[-1]), "agent_approve", "error", note = "ok"),
  row("Unreviewed --agent reject (note required)--> Rejected", "Unreviewed", "agent_reject", "Rejected", note = "bad"),
  row("  ...not without a note", "Unreviewed", "agent_reject", "error"),
  row("  ...not from any other status", c(NA, statuses[-1]), "agent_reject", "error", note = "bad"),
  row("Agent approved --human approve--> Human approved", "Agent approved", "human_approve", "Human approved"),
  row("  ...not from any other status (the human never sees an Unreviewed output)", c(NA, statuses[-2]), "human_approve", "error"),
  row("Agent approved --human reject (note)--> Rejected", "Agent approved", "human_reject", "Rejected", note = "no"),
  row("  ...not without a note", "Agent approved", "human_reject", "error"),
  row("  ...not from any other status", c(NA, statuses[-2]), "human_reject", "error", note = "no"),
  row("Rejected --code changes fingerprint--> Unreviewed", "Rejected", "run", "Unreviewed", fp = "bbb"),
  row("Platform variant of Human approved --agent approve (note)--> Human approved", "Human approved", "agent_approve_variant", "Human approved", note = "font"),
  row("  ...not without a note", "Human approved", "agent_approve_variant", "error"),
  row("  ...not from any other status", c(NA, statuses[-3]), "agent_approve_variant", "error", note = "x"),
  row("unknown events are errors", c(NA, statuses), "nope", "error")
)

test_that("every row of the transition table holds", {
  for (i in seq_len(nrow(transitions))) {
    t <- transitions[i, ]
    state <- if (is.na(t$from)) NULL else list(status = t$from, fingerprint = "aaa")
    event <- list(type = t$event)
    if (!is.na(t$note)) event$note <- t$note
    if (!is.na(t$fp)) event$fingerprint <- t$fp
    label <- sprintf("[%s] from %s", trimws(t$spec), t$from)
    if (t$to == "error") {
      expect_error(review_transition(state, event), class = "review_transition_error", label = label)
    } else {
      expect_equal(review_transition(state, event)$status, t$to, label = label)
    }
  }
})

test_that("a run resets exactly when the fingerprint is new, and records it", {
  runs <- transitions[transitions$event == "run", ]
  for (i in seq_len(nrow(runs))) {
    state <- if (is.na(runs$from[i])) NULL else list(status = runs$from[i], fingerprint = "aaa")
    r <- review_transition(state, list(type = "run", fingerprint = runs$fp[i]))
    expect_equal(r$reset, runs$fp[i] != "aaa" || is.na(runs$from[i]))
    expect_equal(r$fingerprint, runs$fp[i])
  }
})
