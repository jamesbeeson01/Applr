# THROWAWAY (ticket 03). Fingerprints a fixed set of outputs, one of each
# output type, and writes them to results/<platform>/ for compare.R.
#
#   Rscript for_devs/experiments/03-cross-platform/fingerprint_all.R [platform]
#
# platform defaults to $XPLAT_PLATFORM, then "local-<os>". Run from the
# package root.

exp_dir <- "for_devs/experiments/03-cross-platform"
platform <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(platform)) platform <- Sys.getenv("XPLAT_PLATFORM", paste0("local-", tolower(Sys.info()[["sysname"]])))
out_dir <- file.path(exp_dir, "results", platform)
unlink(out_dir, recursive = TRUE)
dir.create(file.path(out_dir, "forms"), recursive = TRUE)

suppressMessages(pkgload::load_all(".", quiet = TRUE, export_all = TRUE))
suppressPackageStartupMessages(library(ggplot2))
source("tests/suite/fingerprint.R")
source(file.path(exp_dir, "slider_p5.R"))

# The cases' own setup, minus load_all. try_show() records errors instead of
# printing them, so console cases keep running after a failing step.
case_env <- function(record) {
  env <- new.env(parent = globalenv())
  env$try_show <- function(expr) tryCatch({
    out <- withVisible(expr)
    if (out$visible) print(out$value)
  }, error = function(e) record("error", e))
  env
}

# ---- serialisers beyond fingerprint.R --------------------------------------

svg_lines <- function(draw, width = 7, height = 5) {
  file <- tempfile(fileext = ".svg")
  on.exit(unlink(file))
  vdiffr:::svglite(file, width = width, height = height)
  tryCatch(with_pinned_options(draw()), finally = grDevices::dev.off())
  normalise_common(readLines(file, warn = FALSE, encoding = "UTF-8"))
}

conditions_lines <- function(conds) {
  blocks <- lapply(conds, function(cnd) c(cnd$kind, cnd$message))
  lines <- unlist(Map(function(b, i) if (i > 1) c("", b) else b, blocks, seq_along(blocks)))
  lines <- cli::ansi_strip(unlist(strsplit(lines, "\n", fixed = TRUE)))
  lines <- chartr("‘’“”", "''\"\"", lines)
  normalise_common(lines)
}

drop_classes <- function(x) {
  if (is.list(x)) {
    nms <- names(x)
    x <- lapply(unclass(x), drop_classes)
    if (!is.null(nms)) x <- x[order(nms, method = "radix")]
    return(x)
  }
  if (is.factor(x)) x <- as.character(x)
  if (is.numeric(x) && !is.integer(x)) x <- signif(x, 6)
  attributes(x) <- if (!is.null(names(x))) list(names = names(x))
  x
}

canonical_json <- function(x) {
  json <- jsonlite::toJSON(drop_classes(x), digits = I(6), auto_unbox = TRUE,
                           null = "null", na = "null", pretty = TRUE)
  normalise_common(strsplit(as.character(json), "\n", fixed = TRUE)[[1]])
}

widget_deps <- function(widget) {
  deps <- c(htmlwidgets::getDependency(class(widget)[1], attr(widget, "package") %||% "plotly"),
            widget$dependencies)
  vapply(deps, function(d) paste(d$name, d$version), "")
}

# ---- outputs -----------------------------------------------------------------

case_header <- function(file) {
  lines <- readLines(file, warn = FALSE)
  field <- function(key) {
    hit <- grep(paste0("^# ", key, ":"), lines, value = TRUE)
    if (length(hit)) trimws(sub(paste0("^# ", key, ":"), "", hit[1])) else NA
  }
  size <- field("SIZE")
  wh <- if (is.na(size)) c(7, 5) else as.numeric(strsplit(size, "x")[[1]])
  list(type = field("TYPE"), func = field("FUNC"), width = wh[1], height = wh[2])
}

# One old case: its drawing (printed ggplots auto-print, as under Rscript) and
# every condition it raises, including those raised while drawing.
run_case <- function(id) {
  file <- file.path("tests/cases", paste0(id, ".R"))
  meta <- case_header(file)
  exprs <- parse(file, keep.source = FALSE)
  exprs <- Filter(function(e) !identical(e, quote(source("tests/_setup.R"))), exprs)
  conds <- list()
  record <- function(kind, cnd) conds[[length(conds) + 1]] <<- list(kind = kind, message = conditionMessage(cnd))
  env <- case_env(record)
  draw <- function() withCallingHandlers(
    tryCatch(for (e in exprs) {
      out <- withVisible(eval(e, env))
      if (out$visible && inherits(out$value, "ggplot")) print(out$value)
    }, error = function(e) record("error", e)),
    warning = function(w) { record("warning", w); invokeRestart("muffleWarning") },
    message = function(m) { record("message", m); invokeRestart("muffleMessage") }
  )
  svg <- svg_lines(draw, meta$width, meta$height)
  out <- list()
  if (!identical(meta$type, "console")) {
    type <- if (meta$func %in% c("slice_2d", "add_slice_2d")) "base graphics" else "static ggplot"
    out[[paste0(id, "__plot")]] <- list(type = type, parts = list(main = svg))
  }
  if (length(conds)) {
    out[[paste0(id, "__conditions")]] <- list(type = "condition text",
                                              parts = list(main = conditions_lines(conds)))
  }
  out
}

plotly_output <- function() {
  w <- scatter_3d(lm(mpg ~ wt + hp, data = mtcars))
  built <- plotly::plotly_build(w)
  figure <- built$x[c("data", "layout", "config")]
  strip <- function(x) {
    if (!is.list(x)) return(x)
    x[c("uid", "elementId")] <- NULL
    lapply(x, strip)
  }
  presets <- list(
    default = list(eye = list(x = 1.25, y = 1.25, z = 1.25)),
    top = list(eye = list(x = 0, y = 0, z = 2.5)),
    side = list(eye = list(x = 2.5, y = 0, z = 0))
  )
  list(scatter_3d__plotly = list(type = "plotly JSON", parts = list(
    figure = canonical_json(strip(figure)),
    presets = canonical_json(presets),
    shell = widget_deps(w)
  )))
}

slider_output <- function(name, recipe) {
  b <- p5_build(recipe)
  set <- list()
  set[[paste0(name, "__slider")]] <- list(type = "slider payload + background", parts = list(
    payload = canonical_json(b$payload),
    data_payload = canonical_json(b$data_payload),
    background = svg_lines(function() print(b$background), 7, 5),
    shell = canonical_json(b$shell)
  ))
  set
}

# A minimal animation: hp sweeps across its range while geom_slice() redraws.
# The frame step returns each frame as data, before any encoder would run.
animation_output <- function() {
  model <- lm(mpg ~ wt + hp, data = mtcars)
  recipe <- function(hp) {
    ggplot(mtcars, aes(wt, mpg)) + geom_point() +
      geom_slice(model, predict_vars = list(hp = hp)) + geom_slice_subtitle()
  }
  values <- seq(min(mtcars$hp), max(mtcars$hp), length.out = 12)
  frames <- lapply(values, function(v) {
    p <- suppressMessages(recipe(v))
    d <- suppressMessages(layer_data(p, 2))
    list(hp = v, subtitle = p$labels$subtitle, x = d$x, y = d$y, colour = d$colour)
  })
  list(hp_sweep__animation = list(type = "animation frame data", parts = list(
    frames = canonical_json(frames),
    style = svg_lines(function() print(suppressMessages(recipe(values[1]))), 7, 5),
    shell = canonical_json(list(n_frames = length(values), fps = 10,
                                duration = length(values) / 10, easing = "linear"))
  )))
}

cases <- c(
  "gs_09_ytransform_log", "gs_17_all_features", "gs_33_interval_confidence",
  "gt_15_band_edges_labeled", "sb_15_narrow_plot_wraps", "cp_03_long_equation_wraps",
  "as_23_interval_confidence", "s2_14_mtcars_log",
  "gs_37_err_data_mismatch", "gs_53_warn_band_nothing_to_band",
  "as_16_err_character_variable", "gt_17_warn_labels_too_wide", "s2_22_deprecated_xaxis_alias"
)

# Each producer is isolated, so one failure is recorded rather than fatal.
safely <- function(label, f) tryCatch(f(), error = function(e) {
  message("FAILED ", label, ": ", conditionMessage(e))
  setNames(list(list(type = "ERROR", parts = list(main = conditionMessage(e)))), label)
})

outputs <- c(
  unlist(lapply(cases, function(id) safely(id, function() run_case(id))), recursive = FALSE),
  safely("scatter_3d__plotly", plotly_output),
  safely("demo_a__slider", function() slider_output("demo_a", recipe_a)),
  safely("demo_b__slider", function() slider_output("demo_b", recipe_b)),
  safely("hp_sweep__animation", animation_output)
)

rows <- do.call(rbind, Map(function(name, o) {
  fp <- fingerprint_output(list(parts = o$parts))
  writeLines(fp$form, file.path(out_dir, "forms", paste0(name, ".txt")), useBytes = TRUE)
  data.frame(output = name, type = o$type, part = c("(all)", names(o$parts)),
             hash = c(fp$fingerprint, unlist(fp$part_hashes)))
}, names(outputs), outputs))
write.csv(rows, file.path(out_dir, "fingerprints.csv"), row.names = FALSE)

ip <- installed.packages()[, c("Package", "Version")]
write.csv(ip[order(ip[, "Package"]), ], file.path(out_dir, "installed.csv"), row.names = FALSE)
writeLines(c(
  capture.output(sessionInfo()),
  "", paste("La_library:", La_library()), paste("La_version:", La_version()),
  capture.output(print(extSoftVersion())),
  paste("l10n_info:", paste(names(l10n_info()), l10n_info(), collapse = ", "))
), file.path(out_dir, "session.txt"))

cat(sprintf("%s: %d outputs -> %s\n", platform, length(outputs), out_dir))
