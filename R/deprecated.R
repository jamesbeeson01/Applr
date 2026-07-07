# Courtesy stubs for removed functions. Each errors with a pointer to its
# replacement so old student code fails with directions, not confusion.
# Drop the stub (and its export) after a release or two.

#' Defunct: use geom_slice() instead
#'
#' `geom_fit()` was removed in favor of [geom_slice()], which does everything
#' it did (prediction lines from a fitted `lm()`, confidence/prediction
#' ribbons, back-transformation) plus grouping, faceting, and held-variable
#' reporting. Calling it is an error that points to the replacement.
#'
#' @param ... Ignored; accepted only so old calls reach the error message.
#'
#' @seealso [geom_slice()]
#' @keywords internal
#' @export
geom_fit <- function(...) {
  slice_abort(
    what = "`geom_fit()` has been removed; use `geom_slice()` instead.",
    hint = paste0("It takes the model the same way, such as 'geom_slice(model)'. ",
                  "For a ribbon use 'interval = \"confidence\"'; ",
                  "instead of 'new_data' use 'predict_vars = list(hp = 110)'.")
  )
}
