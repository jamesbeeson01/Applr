# The output-type contract (spec: "One contract per output type"). Each type
# registers once, in its own file under types/; the runner, store and review
# page reach types only through output_type() and never name one.
#
# A registration gives:
#   serialise(object, states) -> list(parts, engine_version, view)
#       `parts` is a named list of character vectors; the core normalises
#       each part and fingerprints them. `view` is what render() and live()
#       draw from, so views come from the hashed build, never a parallel one.
#   states(declared)          -> named list of states; `declared` is what the
#       case passed to judged_output(), or NULL.
#   render(view, state, file, live) writes one state's view to `file`, as
#       `format` ("png" or "html"). `live` is the live page, if any.
#   view                      the review page's view kind: "image" (one state,
#       compared against the last approved render), "text" (diff of the
#       serialised form) or "states" (sampled states side by side).
#   live(view, file)          optional: writes an interactive HTML page that
#       defines window.applrSetState(state), returning a Promise, so
#       screenshots of states are deterministic.
#   detect(object)            optional: TRUE when an undeclared object is
#       this type. Leave it out when the object alone is ambiguous.
#   mutations                 named list of function(x) -> x, where x is
#       list(object, states). Each changes one input; the contract tests
#       assert that each changes the fingerprint.
#   demo                      the case name whose outputs the contract tests
#       use (tests/testthat/test-case_<demo>.R).

output_types <- new.env()

register_output_type <- function(name, serialise, states, render, view,
                                 format = c("png", "html"), live = NULL,
                                 detect = NULL, mutations = list(), demo = NULL) {
  stopifnot(is.character(name), length(name) == 1, is.function(serialise),
            is.function(states), is.function(render),
            view %in% c("image", "text", "states"),
            is.null(live) || is.function(live), is.null(detect) || is.function(detect),
            is.list(mutations), length(mutations) == 0 || !is.null(names(mutations)),
            all(vapply(mutations, is.function, TRUE)))
  assign(name, list(name = name, serialise = serialise, states = states,
                    render = render, view = view, format = match.arg(format),
                    live = live, detect = detect, mutations = mutations, demo = demo),
         envir = output_types)
  invisible(name)
}

unregister_output_type <- function(name) {
  if (exists(name, envir = output_types, inherits = FALSE)) rm(list = name, envir = output_types)
}

output_type <- function(name) {
  if (!exists(name, envir = output_types, inherits = FALSE)) {
    stop("Unknown output type '", name, "'. Registered: ",
         paste(sort(ls(output_types)), collapse = ", "), call. = FALSE)
  }
  get(name, envir = output_types)
}

# The one place a judged output's type is worked out: the case's declared
# type, else the single registered type whose detect() claims the object.
resolve_output_type <- function(entry) {
  if (!is.null(entry$type)) return(output_type(entry$type))
  hits <- Filter(function(t) !is.null(t$detect) && isTRUE(t$detect(entry$object)),
                 mget(ls(output_types), envir = output_types))
  if (length(hits) != 1) {
    stop("Can't work out the output type of a ", class(entry$object)[1], " (",
         if (length(hits)) paste(names(hits), collapse = " or ") else "no type claims it",
         "). Pass type = to judged_output().", call. = FALSE)
  }
  hits[[1]]
}

# Serialises one declared output through its type. Every part goes through
# the common normalisation here, so no type can skip it.
serialise_output <- function(entry) {
  type <- resolve_output_type(entry)
  states <- type$states(entry$states)
  if (!is.list(states) || !length(states) || is.null(names(states)) || !all(grepl("^[A-Za-z0-9_.-]+$", names(states)))) {
    stop("Output type '", type$name, "' must give a non-empty list of states named with ",
         "letters, digits, '.', '_' or '-'.", call. = FALSE)
  }
  s <- type$serialise(entry$object, states)
  if (!is.list(s$parts) || !length(s$parts) || is.null(names(s$parts))) {
    stop("Output type '", type$name, "' must serialise to named parts.", call. = FALSE)
  }
  s$parts <- lapply(s$parts, normalise_common)
  c(list(type = type, states = states), fingerprint_output(s), list(view = s$view))
}

source_output_types <- function(dir) {
  for (f in sort(list.files(dir, pattern = "\\.R$", full.names = TRUE))) sys.source(f, envir = globalenv())
}
