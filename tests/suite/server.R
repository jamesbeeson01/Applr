# Review server (httpuv): serves the review page in page/, the data it reads
# and the views, and records human decisions. It is the only code that
# writes human_decisions.json. Start it with tests/suite/review.R.

review_port <- function() as.integer(getOption("applr.review_port", 7654))

# Deep link to one output, or to a page view such as "overview".
review_url <- function(output = NULL, view = NULL, port = review_port()) {
  base <- sprintf("http://127.0.0.1:%d/", port)
  if (!is.null(output)) return(paste0(base, "?output=", utils::URLencode(output, reserved = TRUE)))
  if (!is.null(view)) return(paste0(base, "?view=", view))
  base
}

write_decisions <- function(decisions, paths) {
  dir.create(dirname(paths$decisions), showWarnings = FALSE, recursive = TRUE)
  jsonlite::write_json(decisions, paths$decisions, pretty = TRUE, auto_unbox = TRUE)
}

# A human decision on the output's current fingerprint, checked with
# review_transition() and appended to human_decisions.json. `fingerprint` is
# the one the page showed, so a decision on a stale page is refused.
human_decide <- function(id, decision = c("approve", "reject"), note = "", fingerprint,
                         paths = suite_paths()) {
  decision <- match.arg(decision)
  rec <- review_records(paths)[[id]]
  if (is.null(rec)) stop("No such judged output: ", id, call. = FALSE)
  if (!identical(fingerprint, rec$fingerprint)) {
    stop(structure(class = c("review_stale_error", "error", "condition"), list(
      message = "This output changed since the page loaded. Reload and look again.", call = NULL)))
  }
  review_transition(list(status = rec$status, fingerprint = rec$fingerprint),
                    list(type = paste0("human_", decision), note = note))
  decisions <- read_decisions(paths)
  decisions[[length(decisions) + 1]] <- list(id = id, fingerprint = rec$fingerprint,
                                             decision = decision, note = trimws(note %||% ""),
                                             when = now_stamp())
  write_decisions(decisions, paths)
  if (decision == "approve") keep_approved(id, paths)
  invisible(review_records(paths)[[id]])
}

# A view's URL on the server, or NULL when there is no such file.
view_url <- function(file, paths) {
  if (is.null(file) || is.na(file)) return(NULL)
  root <- normalizePath(paths$views, winslash = "/", mustWork = FALSE)
  f <- normalizePath(file, winslash = "/", mustWork = FALSE)
  if (!startsWith(f, paste0(root, "/"))) return(NULL)
  paste0("/views/", utils::URLencode(substring(f, nchar(root) + 2)))
}

read_json_or_null <- function(file) if (file.exists(file)) jsonlite::read_json(file) else NULL

# Everything the page draws, read fresh on every request so a re-run or an
# agent decision shows on reload.
review_api_data <- function(paths, inventory_file, case_dir) {
  inventory <- list(groups = list(), entries = list())
  inventory_error <- NULL
  if (file.exists(inventory_file)) {
    inventory <- tryCatch(read_inventory(inventory_file), error = function(e) {
      inventory_error <<- conditionMessage(e)
      list(groups = list(), entries = list())
    })
  } else {
    inventory_error <- paste("No behaviour inventory yet at", inventory_file)
  }
  outputs <- unname(lapply(review_page_data(paths), function(o) {
    o$states <- lapply(seq_len(nrow(o$states)), function(i) list(
      name = o$states$name[i],
      url = view_url(o$states$file[i], paths),
      approved_url = view_url(o$states$approved_file[i], paths)
    ))
    o$live <- view_url(o$live, paths)
    o$parts <- as.list(o$parts)
    o[c("form", "approved_form")] <- NULL
    o
  }))
  root <- dirname(paths$state)
  list(
    meta = list(commit = git_commit(), generated = now_stamp(), inventory_file = inventory_file),
    outputs = outputs,
    cases = case_index(case_dir, inventory),
    inventory = inventory,
    inventory_error = inventory_error,
    health = list(mutation = read_json_or_null(file.path(root, "mutation_report.json")),
                  tests = read_json_or_null(file.path(root, "test_report.json")))
  )
}

# The current and last approved serialised forms of one output, and the diff
# between them when there is an approved one.
review_api_form <- function(id, paths) {
  now <- file.path(paths$forms, paste0(file_id(id), ".txt"))
  before <- file.path(paths$approved, paste0(file_id(id), ".txt"))
  if (!file.exists(now)) stop("No such judged output: ", id, call. = FALSE)
  approved <- file.exists(before)
  list(form = readLines(now, warn = FALSE),
       approved = if (approved) readLines(before, warn = FALSE),
       diff = if (approved) diff_output(id, paths))
}

respond <- function(status, type, body) {
  list(status = as.integer(status),
       headers = list("Content-Type" = type, "Cache-Control" = "no-store"), body = body)
}

respond_json <- function(x, status = 200) {
  respond(status, "application/json; charset=utf-8",
          as.character(jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", na = "null", digits = NA)))
}

not_found <- function() respond(404, "text/plain", "Not found")

mime_type <- function(file) {
  types <- c(html = "text/html; charset=utf-8", js = "text/javascript; charset=utf-8",
             css = "text/css; charset=utf-8", json = "application/json", png = "image/png",
             svg = "image/svg+xml", txt = "text/plain; charset=utf-8", map = "application/json",
             woff = "font/woff", woff2 = "font/woff2", ttf = "font/ttf")
  unname(types[tolower(tools::file_ext(file))] %|NA|% "application/octet-stream")
}

`%|NA|%` <- function(a, b) if (is.na(a)) b else a

# Serves a file only from inside `root`, so no request can reach the review
# state or anything else beside it.
serve_file <- function(file, root) {
  root <- normalizePath(root, winslash = "/", mustWork = FALSE)
  f <- normalizePath(file, winslash = "/", mustWork = FALSE)
  if (!startsWith(f, paste0(root, "/"))) return(not_found())
  if (!file.exists(f) || dir.exists(f)) return(not_found())
  respond(200, mime_type(f), readBin(f, "raw", file.info(f)$size))
}

parse_query <- function(q) {
  q <- sub("^\\?", "", q %||% "")
  if (!nzchar(q)) return(list())
  kv <- strsplit(strsplit(q, "&", fixed = TRUE)[[1]], "=", fixed = TRUE)
  decode <- function(x) httpuv::decodeURIComponent(gsub("+", " ", x, fixed = TRUE))
  stats::setNames(lapply(kv, function(p) decode(paste(p[-1], collapse = "="))),
                  vapply(kv, function(p) decode(p[1]), ""))
}

# Decisions come only as JSON from the page on this server: a cross-site page
# can't send JSON here without a CORS preflight, which this server never
# answers, and a foreign Origin or Host is refused outright.
decide_request <- function(req, paths) {
  type <- req$CONTENT_TYPE %||% req$HTTP_CONTENT_TYPE %||% ""
  if (!grepl("^application/json", type)) {
    return(respond_json(list(error = "Decisions must be sent as JSON."), 415))
  }
  host <- req$HTTP_HOST %||% ""
  origin <- req$HTTP_ORIGIN %||% paste0("http://", host)
  if (!grepl("^(127\\.0\\.0\\.1|localhost):[0-9]+$", host) || origin != paste0("http://", host)) {
    return(respond_json(list(error = "Decisions are accepted only from the review page."), 403))
  }
  body <- jsonlite::fromJSON(rawToChar(req$rook.input$read()), simplifyVector = TRUE)
  res <- tryCatch(human_decide(body$id %||% "", body$decision %||% "", body$note %||% "",
                               body$fingerprint %||% "", paths),
                  error = function(e) e)
  if (inherits(res, "error")) return(respond_json(list(error = conditionMessage(res)), 409))
  respond_json(list(ok = TRUE, status = res$status))
}

review_app <- function(paths = suite_paths(), page_dir = "tests/suite/page",
                       inventory_file = inventory_path(), case_dir = "tests/testthat") {
  route <- function(req) {
    path <- req$PATH_INFO
    get <- identical(req$REQUEST_METHOD, "GET")
    if (get && path %in% c("/", "/index.html")) return(serve_file(file.path(page_dir, "index.html"), page_dir))
    if (get && startsWith(path, "/page/")) {
      return(serve_file(file.path(page_dir, httpuv::decodeURIComponent(substring(path, 7))), page_dir))
    }
    if (get && startsWith(path, "/views/")) {
      return(serve_file(file.path(paths$views, httpuv::decodeURIComponent(substring(path, 8))), paths$views))
    }
    if (get && path == "/api/data") return(respond_json(review_api_data(paths, inventory_file, case_dir)))
    if (get && path == "/api/form") {
      return(respond_json(review_api_form(parse_query(req$QUERY_STRING)$id %||% "", paths)))
    }
    if (identical(req$REQUEST_METHOD, "POST") && path == "/api/decide") return(decide_request(req, paths))
    not_found()
  }
  list(call = function(req) {
    tryCatch(route(req), error = function(e) respond_json(list(error = conditionMessage(e)), 500))
  })
}

review_server <- new.env()

# Starts the server in the background of this R session (httpuv runs it
# whenever R is idle) and opens the page. A server already running here is
# stopped first.
start_review_server <- function(port = review_port(), open = interactive(), ...) {
  stop_review_server()
  review_server$handle <- httpuv::startServer("127.0.0.1", port, review_app(...))
  url <- review_url(port = port)
  message("Review page: ", url)
  if (open) utils::browseURL(url)
  invisible(url)
}

stop_review_server <- function() {
  if (!is.null(review_server$handle)) httpuv::stopServer(review_server$handle)
  review_server$handle <- NULL
  invisible()
}
