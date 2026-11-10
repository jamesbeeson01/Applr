# Condition text (spec: "Condition text"). The object is the call as a
# function. One state holds every condition it raises, in order, including
# those raised while a returned ggplot is drawn, since a user sees those too.

# The call, with a returned ggplot drawn on a null device.
draw_call <- function(call) function() {
  value <- call()
  if (inherits(value, "ggplot")) {
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off())
    print(value)
  }
  invisible(value)
}

capture_conditions <- function(call) {
  conds <- list()
  record <- function(kind, cnd) {
    conds[[length(conds) + 1]] <<- list(kind = kind, message = conditionMessage(cnd))
  }
  with_pinned_options(withCallingHandlers(
    tryCatch(draw_call(call)(), error = function(e) record("error", e)),
    warning = function(w) { record("warning", w); invokeRestart("muffleWarning") },
    message = function(m) { record("message", m); invokeRestart("muffleMessage") }
  ))
  conds
}

# One block per condition: its kind, then the message verbatim. ANSI codes
# go, and curly quotes become straight as a safety net behind useFancyQuotes.
conditions_form <- function(conds) {
  if (!length(conds)) return("(no conditions)")
  blocks <- lapply(seq_along(conds), function(i) {
    c(if (i > 1) "", conds[[i]]$kind, strsplit(conds[[i]]$message, "\n", fixed = TRUE)[[1]])
  })
  lines <- cli::ansi_strip(unlist(blocks))
  chartr("\u2018\u2019\u201c\u201d", "''\"\"", lines)
}

register_output_type(
  "conditions",
  states = function(declared) list(conditions = NULL),
  serialise = function(call, states) {
    stopifnot(is.function(call))
    form <- conditions_form(capture_conditions(call))
    list(parts = list(main = form), view = form)
  },
  render = function(form, state, file, live) {
    writeLines(c("<!doctype html><meta charset='utf-8'><pre>",
                 htmltools::htmlEscape(form), "</pre>"), file, useBytes = TRUE)
  },
  view = "text",
  format = "html",
  demo = "condition_imputed_values",
  mutations = list(
    extra = function(x) { f <- x$object; x$object <- function() { v <- f(); warning("Mutated"); v }; x },
    drop_messages = function(x) { f <- draw_call(x$object); x$object <- function() suppressMessages(f()); x },
    kind = function(x) {
      f <- draw_call(x$object)
      x$object <- function() withCallingHandlers(f(), message = function(m) {
        warning(conditionMessage(m), call. = FALSE)
        invokeRestart("muffleMessage")
      })
      x
    }
  )
)
