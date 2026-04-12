# run_all.R — Run all geom_slice test cases and report results.
# Run from the package root:
#   Rscript testing/run_all.R

cases <- sort(list.files("testing/cases", pattern = "^gs_.*\\.R$", full.names = TRUE))

if (length(cases) == 0) {
  stop("No test cases found in testing/cases/. Are you running from the package root?")
}

cat(sprintf("Running %d geom_slice test cases...\n\n", length(cases)))

results <- lapply(cases, function(f) {
  cat(sprintf("  %-52s", basename(f)))
  out <- tryCatch(
    source(f, local = TRUE, echo = FALSE),
    error   = function(e) structure(list(message = conditionMessage(e)), class = "error"),
    warning = function(w) structure(list(message = conditionMessage(w)), class = "warning_caught")
  )
  if (inherits(out, "error")) {
    cat(sprintf("FAIL\n    Error: %s\n", out$message))
    list(file = basename(f), status = "FAIL", msg = out$message)
  } else {
    cat("OK\n")
    list(file = basename(f), status = "OK", msg = NA)
  }
})

# Summary
passed <- sum(sapply(results, function(r) r$status == "OK"))
failed <- sum(sapply(results, function(r) r$status == "FAIL"))
cat(sprintf("\n%d/%d passed", passed, length(results)))
if (failed > 0) {
  cat(sprintf("  (%d FAILED)\n", failed))
  cat("\nFailed tests:\n")
  for (r in results[sapply(results, function(r) r$status == "FAIL")]) {
    cat(sprintf("  - %s\n    %s\n", r$file, r$msg))
  }
} else {
  cat(" — all tests passed!\n")
}
