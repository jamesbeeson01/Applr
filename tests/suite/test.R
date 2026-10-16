# Unit tests for the suite's own infrastructure. Run from the package root:
#   Rscript tests/suite/test.R
testthat::test_dir("tests/suite/unit", reporter = "summary", stop_on_failure = TRUE)
