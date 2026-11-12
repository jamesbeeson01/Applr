# Returned text, such as an equation, a subtitle or a label: wording judged
# for taste, like condition text but for strings a function returns. The
# object is a character vector, or a list of strings; names, when given,
# head each entry, so one output can show several representative examples.

text_form <- function(x) {
  x <- as.list(x)
  if (!length(x)) return("(no text)")
  labels <- names(x) %||% rep("", length(x))
  unlist(lapply(seq_along(x), function(i) {
    c(if (i > 1) "", if (nzchar(labels[i])) paste0("[", labels[i], "]"),
      strsplit(as.character(x[[i]]), "\n", fixed = TRUE)[[1]])
  }))
}

register_output_type(
  "returned_text",
  detect = function(x) is.character(x),
  states = function(declared) list(text = NULL),
  serialise = function(x, states) {
    stopifnot(is.character(x) || (is.list(x) && all(vapply(x, is.character, TRUE))))
    form <- text_form(x)
    list(parts = list(main = form), view = form)
  },
  render = function(form, state, file, live) {
    writeLines(c("<!doctype html><meta charset='utf-8'><pre>",
                 htmltools::htmlEscape(form), "</pre>"), file, useBytes = TRUE)
  },
  view = "text",
  format = "html",
  demo = "text_lm_equation_styles",
  mutations = list(
    edit = function(x) { x$object[[1]] <- paste0(x$object[[1]], "x"); x },
    extra = function(x) { x$object <- c(x$object, extra = "Mutated"); x },
    order = function(x) { x$object <- rev(x$object); x },
    label = function(x) { names(x$object)[1] <- "mutated"; x }
  )
)
