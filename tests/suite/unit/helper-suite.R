# testthat runs these files from tests/suite/unit. The suite under test is
# the one these files sit in, so a mutated copy tests itself; the package
# and its cases come from APPLR_PKG_ROOT when the copy lives elsewhere.
suite_dir <- normalizePath("..", winslash = "/")
root <- Sys.getenv("APPLR_PKG_ROOT", normalizePath(file.path(suite_dir, "..", ".."), winslash = "/"))
suppressMessages(pkgload::load_all(root, quiet = TRUE))
source(file.path(suite_dir, "load.R"))
load_suite(suite_dir)

case_dir <- file.path(root, "tests/testthat")
case_path <- function(case) file.path(case_dir, paste0("test-case_", case, ".R"))

# Copies case files and the judged_output() helper into a fresh folder. `edit`
# is c(from, to), a text edit to the first case, so a test can change one
# input of a case at a time; `extra` lines are appended to it.
case_copy <- function(cases = "single_predictor_line", edit = NULL, extra = NULL) {
  dir <- tempfile("case")
  dir.create(dir)
  file.copy(file.path(case_dir, "helper-judged.R"), dir)
  for (i in seq_along(cases)) {
    txt <- readLines(case_path(cases[i]))
    if (i == 1 && !is.null(edit)) {
      stopifnot(any(grepl(edit[1], txt, fixed = TRUE)))
      txt <- sub(edit[1], edit[2], txt, fixed = TRUE)
    }
    if (i == 1) txt <- c(txt, extra)
    writeLines(txt, file.path(dir, basename(case_path(cases[i]))))
  }
  dir
}

temp_paths <- function() {
  root <- tempfile("suite")
  suite_paths(root, file.path(root, "views"))
}

# The demo static case, and a copy of it with one visible change.
renamed <- function() case_copy(edit = c('title = "Single predictor"', 'title = "Renamed"'))
id <- "single_predictor_line/plot"
view_file <- function(paths) file.path(paths$views, "single_predictor_line__plot", "plot.png")

# The review server's app, with a request built as httpuv hands it over.
test_app <- function(paths, case_dir = case_copy(), inventory_file = inventory_path(root)) {
  review_app(paths, page_dir = file.path(suite_dir, "page"), inventory_file = inventory_file,
             case_dir = case_dir)
}
call_app <- function(app, path, method = "GET", body = NULL, query = "", type = "application/json",
                     host = "127.0.0.1:7654", origin = NULL) {
  req <- list(PATH_INFO = path, REQUEST_METHOD = method, QUERY_STRING = query, HTTP_HOST = host,
              HTTP_CONTENT_TYPE = type, rook.input = list(read = function(...) charToRaw(body %||% "")))
  if (!is.null(origin)) req$HTTP_ORIGIN <- origin
  app$call(req)
}
json_body <- function(res) jsonlite::fromJSON(res$body, simplifyVector = FALSE)
