# Review status rules as a pure function (spec: "Review status rules").
#
# state: NULL for an output never seen, else list(status, fingerprint).
# event: list(type, fingerprint | note).
# Returns list(status, fingerprint, reset); `reset` is TRUE when a new
# fingerprint sent the output back to Unreviewed, so stale notes can go.

review_transition <- function(state, event) {
  fail <- function(msg) stop(structure(
    class = c("review_transition_error", "error", "condition"),
    list(message = msg, call = NULL)
  ))
  need_note <- function() {
    if (!is.character(event$note) || !nzchar(trimws(event$note[1]))) {
      fail(paste0("'", event$type, "' requires a note."))
    }
  }
  need_status <- function(from) {
    if (is.null(state) || !state$status %in% from) {
      fail(sprintf("'%s' needs status %s, not %s.", event$type,
                   paste(from, collapse = " or "),
                   if (is.null(state)) "none" else state$status))
    }
  }
  keep <- function(status) list(status = status, fingerprint = state$fingerprint, reset = FALSE)

  switch(event$type,
    run = {
      if (is.null(state) || !identical(state$fingerprint, event$fingerprint)) {
        list(status = "Unreviewed", fingerprint = event$fingerprint, reset = TRUE)
      } else {
        keep(state$status)
      }
    },
    agent_approve = { need_note(); need_status("Unreviewed"); keep("Agent approved") },
    agent_reject = { need_note(); need_status("Unreviewed"); keep("Rejected") },
    human_approve = { need_status("Agent approved"); keep("Human approved") },
    human_reject = { need_note(); need_status("Agent approved"); keep("Rejected") },
    agent_approve_variant = { need_note(); need_status("Human approved"); keep("Human approved") },
    fail(paste0("Unknown event type '", event$type, "'."))
  )
}
