# Fingerprints for judged outputs (spec: "Fingerprints"). Dev-only: needs
# vdiffr and digest, which are not package dependencies.

`%||%` <- function(a, b) if (is.null(a)) b else a

suite_options <- list(
  useFancyQuotes = FALSE, cli.unicode = FALSE,
  digits = 7, OutDec = ".", width = 80
)

with_pinned_options <- function(code) {
  old <- options(suite_options)
  on.exit(options(old))
  force(code)
}

path_variants <- function(path) {
  short <- if (.Platform$OS.type == "windows") {
    tryCatch(utils::shortPathName(path), error = function(e) path)
  } else path
  v <- unique(c(
    path, short, gsub("\\\\", "/", short),
    normalizePath(path, winslash = "/", mustWork = FALSE),
    normalizePath(path, winslash = "\\", mustWork = FALSE)
  ))
  v[order(-nchar(v))]
}

# Nearest ancestor of the working directory holding a DESCRIPTION file.
package_root <- function(from = getwd()) {
  dir <- normalizePath(from, winslash = "/")
  while (!file.exists(file.path(dir, "DESCRIPTION"))) {
    parent <- dirname(dir)
    if (identical(parent, dir)) return(from)
    dir <- parent
  }
  dir
}

# Order matters: the package root usually sits inside the home folder.
default_path_map <- function() {
  home <- Sys.getenv("USERPROFILE", Sys.getenv("HOME"))
  list(
    "<tmp>" = tempdir(),
    "<pkg>" = package_root(),
    "<home>" = home
  )
}

# Common normalisation: line endings, trailing whitespace, absolute paths,
# negative zero. Takes and returns a character vector of lines.
normalise_common <- function(lines, path_map = default_path_map()) {
  lines <- sub("\r+$", "", lines)
  lines <- sub("[ \t]+$", "", lines)
  for (token in names(path_map)) {
    if (!nzchar(path_map[[token]])) next
    for (p in path_variants(path_map[[token]])) {
      lines <- gsub(p, token, lines, fixed = TRUE)
    }
  }
  # "-0", "-0.00" lose the sign; "-0.5" and "1e-05" are untouched.
  gsub("(?<![A-Za-z0-9_.])-(0+(?:\\.0+)?)(?![0-9.])", "\\1", lines, perl = TRUE)
}

# Joins named parts, each under a "--- <name>" header; a lone unnamed part
# has no header.
assemble_form <- function(parts) {
  if (length(parts) == 1 && !nzchar(names(parts) %||% "")) {
    return(paste(parts[[1]], collapse = "\n"))
  }
  paste(
    unlist(Map(function(name, lines) c(paste("---", name), lines),
               names(parts), parts), use.names = FALSE),
    collapse = "\n"
  )
}

hash_text <- function(text) {
  substr(digest::digest(enc2utf8(paste0(text, "\n")), algo = "sha256",
                        serialize = FALSE), 1, 12)
}

# Static ggplot: fixed-font SVG from vdiffr's engine. The plot is wrapped in
# a function so it keeps the theme users see, not theme_test().
serialise_static_plot <- function(plot) {
  file <- tempfile(fileext = ".svg")
  on.exit(unlink(file))
  with_pinned_options(vdiffr::write_svg(function() print(plot), file))
  lines <- readLines(file, warn = FALSE, encoding = "UTF-8")
  head <- paste(utils::head(lines, 5), collapse = " ")
  engine <- regmatches(head, regexpr("data-engine-version='[^']*'", head))
  if (length(engine) != 1) stop("vdiffr SVG has no data-engine-version in its header.", call. = FALSE)
  list(
    parts = list(main = normalise_common(lines)),
    engine_version = sub("data-engine-version='([^']*)'", "\\1", engine)
  )
}

# One fingerprint for the whole output, plus the hash of each part.
fingerprint_output <- function(serialised) {
  parts <- serialised$parts
  names(parts) <- if (length(parts) == 1) "" else names(parts)
  form <- assemble_form(parts)
  list(
    fingerprint = hash_text(form),
    part_hashes = lapply(serialised$parts, function(l) hash_text(paste(l, collapse = "\n"))),
    form = form,
    engine_version = serialised$engine_version %||% ""
  )
}

fingerprint_static_plot <- function(plot) fingerprint_output(serialise_static_plot(plot))
