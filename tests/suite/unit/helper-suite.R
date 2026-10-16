# testthat runs these files from tests/suite/unit, so anchor on the package root.
root <- normalizePath(file.path(getwd(), "..", "..", ".."), winslash = "/")
suppressMessages(pkgload::load_all(root, quiet = TRUE))
for (f in c("fingerprint", "status", "store")) {
  source(file.path(root, "tests/suite", paste0(f, ".R")))
}

case_file <- file.path(root, "tests/testthat/test-case_single_predictor_line.R")

# Copies the case and its helper into a fresh folder, applying a text edit,
# so a test can change one input of the case at a time.
mutated_case_dir <- function(from = NULL, to = NULL, extra = NULL) {
  dir <- tempfile("case")
  dir.create(dir)
  file.copy(file.path(root, "tests/testthat/helper-judged.R"), dir)
  txt <- readLines(case_file)
  if (!is.null(from)) {
    stopifnot(any(grepl(from, txt, fixed = TRUE)))
    txt <- sub(from, to, txt, fixed = TRUE)
  }
  writeLines(c(txt, extra), file.path(dir, basename(case_file)))
  dir
}

case_fingerprint <- function(from = NULL, to = NULL, extra = NULL) {
  dir <- mutated_case_dir(from, to, extra)
  r <- run_case_file(file.path(dir, basename(case_file)))
  fingerprint_static_plot(r$outputs[[1]])$fingerprint
}

temp_paths <- function() {
  root <- tempfile("suite")
  suite_paths(root, file.path(root, "png"))
}
