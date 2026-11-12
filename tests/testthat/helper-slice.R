# Built data of a plot's `which`-th geom_slice() layer, read with messages
# silenced: imputation and back-transform messages are condition cases' job.
slice_data <- function(p, which = 1) {
  i <- which(vapply(p$layers, function(l) inherits(l$stat, "StatSlice") &&
                      !inherits(l$stat, "StatSliceText"), TRUE))[which]
  suppressMessages(ggplot2::layer_data(p, i))
}

# Built data of a plot's geom_slice_text() layers, stacked.
slice_text_data <- function(p) {
  i <- which(vapply(p$layers, function(l) inherits(l$stat, "StatSliceText"), TRUE))
  do.call(rbind, lapply(i, function(k) suppressMessages(ggplot2::layer_data(p, k))))
}

# The model's prediction on a grid, as an unnamed vector.
predicted <- function(model, newdata, ...) unname(stats::predict(model, newdata, ...))

# Every condition a call raises, in order, and what it returned (a ggplot is
# built, so build-time conditions count). An error wrapped by ggplot2's
# "Problem while ..." chain is recorded by its innermost message.
conditions_of <- function(call) {
  conds <- list()
  add <- function(kind, cnd) conds[[length(conds) + 1]] <<- list(kind = kind, message = conditionMessage(cnd))
  completed <- FALSE
  value <- tryCatch(
    withCallingHandlers({
      v <- call()
      if (inherits(v, "ggplot")) v <- ggplot2::ggplot_build(v)
      completed <- TRUE
      v
    },
    warning = function(w) { add("warning", w); invokeRestart("muffleWarning") },
    message = function(m) { add("message", m); invokeRestart("muffleMessage") }),
    error = function(e) {
      while (!is.null(e$parent)) e <- e$parent
      add("error", e)
      NULL
    })
  list(kinds = vapply(conds, `[[`, "", "kind"), messages = vapply(conds, `[[`, "", "message"),
       value = value, completed = completed)
}

# The two-part format (for_devs/decisions.Rmd): any line after the first is
# the indented hint.
two_part <- function(message) {
  lines <- strsplit(message, "\n", fixed = TRUE)[[1]]
  length(lines) <= 2 && all(startsWith(lines[-1], "    "))
}

# Declares a call's conditions as a judged output and checks them: the kinds
# raised, in order; that some message contains each of `has` and is in the
# two-part format; and, unless the call errors, that it finished, building
# its plot (a ggplot is built; base graphics have drawn).
raises <- function(name, call, kinds, has = character(), format = TRUE) {
  judged_output(name, call, type = "conditions")
  testthat::test_that(paste0(name, " raises ", paste(kinds, collapse = ", ")), {
    r <- conditions_of(call)
    testthat::expect_equal(r$kinds, kinds)
    for (h in has) {
      hit <- grepl(h, r$messages, fixed = TRUE)
      testthat::expect_true(any(hit), label = paste0("a message containing '", h, "'"))
      if (format && any(hit)) testthat::expect_true(two_part(r$messages[hit][1]), label = paste0("'", h, "' message in two-part format"))
    }
    if (!"error" %in% kinds) testthat::expect_true(r$completed, label = "the call finished and its plot was built")
  })
}

# A plot's subtitle (or caption) once every layer has been added, with the
# messages its construction raises silenced.
annotation_of <- function(p, what = "subtitle") p$labels[[what]]
