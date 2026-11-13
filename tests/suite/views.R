# Views of judged outputs: PNGs, HTML and screenshots, for review only and
# never fingerprinted. Screenshots need headless Chrome via chromote.

png_view <- function(file, draw) {
  grDevices::png(file, width = 800, height = 600, res = 100)
  on.exit(grDevices::dev.off())
  draw()
}

# Writes a widget page with its dependencies in a lib folder beside it.
save_live_widget <- function(widget, file) {
  htmlwidgets::saveWidget(widget, file, selfcontained = FALSE, libdir = "lib")
}

# Seconds. Generous, because Chrome is slow to load a widget when the
# machine is busy.
screenshot_timeout <- 60

screenshot_session <- local({
  session <- NULL
  function() {
    if (is.null(session) || !session$is_active()) {
      old <- options(chromote.timeout = screenshot_timeout)
      on.exit(options(old))
      # Two processes starting Chrome at once (as the mutation check's copies
      # do) can leave one without a debugging port; a fresh Chrome fixes it.
      session <<- tryCatch(chromote::ChromoteSession$new(width = 800, height = 600), error = function(e) {
        Sys.sleep(stats::runif(1, 1, 5))
        chromote::set_default_chromote_object(chromote::Chromote$new())
        chromote::ChromoteSession$new(width = 800, height = 600)
      })
    }
    session
  }
})

# Opens a live page, waits for its window.applrSetState hook, sets `state`
# through it and screenshots the result.
screenshot_state <- function(live, state, file) {
  b <- screenshot_session()
  loaded <- b$Page$loadEventFired(wait_ = FALSE, timeout_ = screenshot_timeout)
  b$Page$navigate(paste0("file:///", normalizePath(live, winslash = "/")), wait_ = FALSE)
  b$wait_for(loaded)
  ready <- FALSE
  for (i in seq_len(screenshot_timeout * 10)) {
    ready <- isTRUE(b$Runtime$evaluate("window.applrReady === true")$result$value)
    if (ready) break
    Sys.sleep(0.1)
  }
  if (!ready) stop("Live page never defined window.applrSetState: ", live, call. = FALSE)
  js <- sprintf("Promise.resolve(window.applrSetState(%s)).then(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))))",
                jsonlite::toJSON(state, auto_unbox = TRUE, null = "null"))
  b$Runtime$evaluate(js, awaitPromise = TRUE, timeout_ = screenshot_timeout)
  b$screenshot(file, selector = "html", show = FALSE)
  invisible(file)
}

view_dir <- function(id, paths, approved = FALSE) {
  if (approved) file.path(paths$views, "approved", file_id(id)) else file.path(paths$views, file_id(id))
}

# Writes every view of one output: its live page, if the type has one, then
# one file per state.
render_views <- function(serialised, id, paths) {
  type <- serialised$type
  dir <- view_dir(id, paths)
  unlink(dir, recursive = TRUE)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  live <- NULL
  if (!is.null(type$live)) {
    live <- file.path(dir, "live.html")
    type$live(serialised$view, live)
  }
  for (name in names(serialised$states)) {
    type$render(serialised$view, serialised$states[[name]],
                file.path(dir, paste0(name, ".", type$format)), live)
  }
  invisible(dir)
}

views_present <- function(serialised, id, paths) {
  files <- file.path(view_dir(id, paths), paste0(names(serialised$states), ".", serialised$type$format))
  all(file.exists(files))
}
