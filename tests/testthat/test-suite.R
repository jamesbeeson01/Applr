# Thin testthat shim over the custom suite in testing/ (see testing/README.md).
#
# The real runner is `Rscript testing/run.R`; this wrapper re-runs it and
# turns its per-case results into testthat expectations, so devtools::test()
# and CI report the same cases without duplicating any test logic.
#
# testing/ is .Rbuildignore'd, so inside R CMD check on the built tarball this
# skips — it only runs from a source checkout. Note an OK here means each case
# ran and matched its console snapshot; the visual comparison against
# testing/reference/ images remains a human step (testing/report.Rmd).

test_that("custom testing/ suite passes", {
  root <- normalizePath(test_path("..", ".."), mustWork = TRUE)
  skip_if(!dir.exists(file.path(root, "testing")),
          "testing/ suite not present (built package)")
  skip_if_not_installed("devtools") # testing/_setup.R loads via load_all()

  old_wd <- setwd(root)
  on.exit(setwd(old_wd), add = TRUE)

  rscript <- file.path(R.home("bin"), "Rscript")
  out <- suppressWarnings(
    system2(rscript, "testing/run.R", stdout = TRUE, stderr = TRUE)
  )

  results_csv <- file.path("testing", "output", "_results.csv")
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
