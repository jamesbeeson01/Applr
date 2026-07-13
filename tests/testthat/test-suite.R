# Thin testthat shim over the custom suite in tests/ (see tests/README.md).
#
# The real runner is `Rscript tests/run.R`; this wrapper re-runs it and
# turns its per-case results into testthat expectations, so devtools::test()
# and CI report the same cases without duplicating any test logic.
#
# The custom-suite files inside tests/ (run.R, cases/, ...) are
# .Rbuildignore'd, so inside R CMD check on the built tarball this skips —
# it only runs from a source checkout. Note an OK here means each case
# ran and matched its console snapshot; the visual comparison against
# tests/reference/ images remains a human step (tests/report.Rmd).

test_that("custom tests/ suite passes", {
  root <- normalizePath(test_path("..", ".."), mustWork = TRUE)
  skip_if(!file.exists(file.path(root, "tests", "run.R")),
          "tests/ suite not present (built package)")
  skip_if_not_installed("devtools") # tests/_setup.R loads via load_all()

  old_wd <- setwd(root)
  on.exit(setwd(old_wd), add = TRUE)

  rscript <- file.path(R.home("bin"), "Rscript")
  out <- suppressWarnings(
    system2(rscript, "tests/run.R", stdout = TRUE, stderr = TRUE)
  )

  results_csv <- file.path("tests", "output", "_results.csv")
  if (!file.exists(results_csv)) {
    fail(paste(c("runner produced no _results.csv:", out), collapse = "\n"))
  }
  results <- utils::read.csv(results_csv, stringsAsFactors = FALSE)
  expect_gt(nrow(results), 0)

  bad <- results[results$status != "OK", ]
  expect(
    nrow(bad) == 0,
    sprintf("%d case(s) not OK:\n%s", nrow(bad),
            paste0("  ", bad$id, " [", bad$status, "] ", bad$msg,
                   collapse = "\n"))
  )
})
