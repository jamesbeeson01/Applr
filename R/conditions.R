#' Standard package conditions
#'
#' Internal helpers that enforce the message convention documented in
#' `for_devs/decisions.Rmd`: a first line stating *what happened* (naming the
#' offending value), optionally followed by an indented line stating *how to
#' fix it* with a concrete, copy-pasteable example.
#'
#' Prefer these over bare `stop()` / `warning()` / `message()` so that the
#' format lives in one place and stays consistent across the package.
#'
#' - `slice_abort()` stops execution (the request cannot proceed).
#' - `slice_warn()` issues a warning (proceeds, but the result is likely wrong).
#' - `slice_inform()` prints a message (a normal but hidden choice, e.g. an
#'   imputed value).
#'
#' @param what Character. What happened. Name the offending value in backticks.
#' @param hint Character or `NULL`. How to fix it, ideally copy-pasteable.
#'   Rendered on a new, indented line. Omit when there is nothing to act on.
#'
#' @return Called for their side effect (a condition). `slice_message()` returns
#'   the assembled string.
#' @keywords internal
#' @noRd
slice_message <- function(what, hint = NULL) {
  if (is.null(hint)) {
    what
  } else {
    # Hint goes on a new, indented line per the decisions.Rmd format
    paste0(what, "\n    ", hint)
  }
}

slice_abort <- function(what, hint = NULL) {
  # call. = FALSE keeps the helper itself out of the displayed call
  stop(slice_message(what, hint), call. = FALSE)
}

slice_warn <- function(what, hint = NULL) {
  warning(slice_message(what, hint), call. = FALSE)
}

slice_inform <- function(what, hint = NULL) {
  message(slice_message(what, hint))
}
