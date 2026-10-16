# The three trust tests from the spec's "Trusting a fingerprint", for
# static plots.

test_that("completeness: the fingerprint comes from the plot the case judges", {
  # Two plots in the file; both are declared, under different names.
  extra <- c("q <- p + ggplot2::labs(title = 'other')", "judged_output('q', q)")
  dir <- mutated_case_dir(extra = extra)
  r <- run_case_file(file.path(dir, basename(case_file)))
  q <- r$outputs[["single_predictor_line/q"]]
  p <- r$outputs[["single_predictor_line/plot"]]
  expect_false(fingerprint_static_plot(q)$fingerprint == fingerprint_static_plot(p)$fingerprint)

  # What is stored is exactly what is hashed, and is the registered object's form.
  paths <- temp_paths()
  run_suite(dir, paths)
  rec <- read_state(paths)[["single_predictor_line/q"]]
  form <- readLines(file.path(paths$forms, "single_predictor_line__q.txt"))
  expect_equal(rec$fingerprint, hash_text(paste(form, collapse = "\n")))
  expect_equal(form, strsplit(fingerprint_static_plot(q)$form, "\n")[[1]])
})

test_that("sensitivity: changing one input changes the fingerprint", {
  base <- case_fingerprint()
  expect_false(base == case_fingerprint("2 * df$x", "3 * df$x"))
  expect_false(base == case_fingerprint(
    extra = c("p <- p + ggplot2::theme(panel.grid = ggplot2::element_blank())",
              "judged_output('plot', p)")
  ))
  expect_false(base == case_fingerprint('title = "Single predictor"', 'title = "Single predictors"'))
})

test_that("stability: two builds in different temp folders and sessions agree", {
  script <- tempfile(fileext = ".R")
  writeLines(c(
    sprintf('setwd("%s")', root),
    'suppressMessages(pkgload::load_all(".", quiet = TRUE))',
    'for (f in c("fingerprint", "status", "store")) source(file.path("tests/suite", paste0(f, ".R")))',
    sprintf('r <- run_case_file("%s")', case_file),
    'cat("FP:", fingerprint_static_plot(r$outputs[[1]])$fingerprint, "\\n")'
  ), script)
  build <- function() {
    tmp <- tempfile("tmp")
    dir.create(tmp)
    out <- withr::with_envvar(
      c(TMPDIR = tmp, TMP = tmp, TEMP = tmp),
      suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), script,
                               stdout = TRUE, stderr = TRUE))
    )
    grep("^FP:", out, value = TRUE)
  }
  a <- build()
  b <- build()
  expect_length(a, 1)
  expect_equal(a, b)
  expect_equal(trimws(sub("FP: ", "", a)), case_fingerprint())
})
