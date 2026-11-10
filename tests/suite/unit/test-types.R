test_that("an undeclared type is worked out from the object, or must be declared", {
  expect_equal(resolve_output_type(list(object = ggplot2::ggplot()))$name, "static_plot")
  expect_equal(resolve_output_type(list(object = function() 1, type = "conditions"))$name, "conditions")
  expect_error(resolve_output_type(list(object = function() 1)), "Pass type =")
  expect_error(resolve_output_type(list(object = 1, type = "nope")), "Unknown output type")
})

test_that("a type's states must be a named list with file-safe names", {
  bad <- function(states) {
    register_output_type("bad", states = function(d) states, view = "text", format = "html",
                         serialise = function(x, s) list(parts = list(main = "x"), view = x),
                         render = function(...) NULL)
    withr::defer(unregister_output_type("bad"))
    serialise_output(list(object = 1, type = "bad"))
  }
  expect_error(bad(list()), "states")
  expect_error(bad(list(1)), "states")
  expect_error(bad(list(`a/b` = 1)), "states")
  expect_equal(bad(list(a = 1))$fingerprint, hash_text("x"))
})

test_that("every part goes through the common normalisation", {
  register_output_type("raw", states = function(d) list(s = NULL), view = "text", format = "html",
                       serialise = function(x, s) list(parts = list(a = "-0 \r", b = "y"), view = x),
                       render = function(...) NULL)
  withr::defer(unregister_output_type("raw"))
  expect_equal(serialise_output(list(object = 1, type = "raw"))$form, "--- a\n0\n--- b\ny")
})

test_that("the core never names an output type", {
  core <- file.path(suite_dir, c("fingerprint.R", "types.R", "status.R", "store.R", "views.R", "suite.R"))
  text <- unlist(lapply(core, readLines))
  for (type in ls(output_types)) {
    expect_false(any(grepl(type, text, fixed = TRUE)), label = paste("core mentions", type))
  }
})
