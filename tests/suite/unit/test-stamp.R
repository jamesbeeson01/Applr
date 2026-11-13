# suite_code_hash() decides when the mutation report is out of date.

hash_copy <- function() {
  dir <- tempfile("hash")
  dir.create(file.path(dir, "suite"), recursive = TRUE)
  dir.create(file.path(dir, "cases"))
  file.copy(list.files(suite_dir, full.names = TRUE), file.path(dir, "suite"), recursive = TRUE)
  file.copy(list.files(case_dir, full.names = TRUE), file.path(dir, "cases"))
  list(suite = file.path(dir, "suite"), cases = file.path(dir, "cases"))
}
hash_of <- function(d) suite_code_hash(d$suite, d$cases)

test_that("adding or editing a case the unit tests don't read leaves the hash alone", {
  d <- hash_copy()
  before <- hash_of(d)
  writeLines("1", file.path(d$cases, "test-case_brand_new.R"))
  expect_equal(hash_of(d), before)
})

test_that("editing suite code, a unit test or a demo case changes the hash", {
  for (f in c("suite/status.R", "suite/unit/test-status.R", "cases/test-case_single_predictor_line.R",
              "cases/helper-judged.R")) {
    d <- hash_copy()
    before <- hash_of(d)
    path <- file.path(dirname(d$suite), f)
    cat("# edit\n", file = path, append = TRUE)
    expect_false(hash_of(d) == before, label = paste("editing", f))
  }
})

test_that("line endings don't change the hash", {
  d <- hash_copy()
  before <- hash_of(d)
  path <- file.path(d$suite, "status.R")
  lines <- readLines(path)
  con <- file(path, "wb")
  writeLines(lines, con, sep = "\r\n")
  close(con)
  expect_equal(hash_of(d), before)
})
