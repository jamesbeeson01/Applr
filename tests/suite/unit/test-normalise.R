test_that("line endings and trailing whitespace are removed", {
  expect_equal(normalise_common(c("a \r", "b\t"), path_map = list()), c("a", "b"))
})

test_that("absolute paths become tokens", {
  map <- list("<tmp>" = tempdir(), "<home>" = "C:/Users/someone")
  out <- normalise_common(c(paste0("x ", tempdir(), "/f"), "C:/Users/someone/doc"), map)
  expect_equal(out, c("x <tmp>/f", "<home>/doc"))
})

test_that("negative zero loses its sign but real negatives do not", {
  out <- normalise_common(c("a -0 b", "c -0.00,", "d -0.5", "e -0.05", "f 1e-05", "g clip-path"), list())
  expect_equal(out, c("a 0 b", "c 0.00,", "d -0.5", "e -0.05", "f 1e-05", "g clip-path"))
})

test_that("multi-part forms get headers; a lone unnamed part does not", {
  expect_equal(assemble_form(list(main = "x")), "--- main\nx")
  expect_equal(assemble_form(stats::setNames(list("x"), "")), "x")
  expect_equal(assemble_form(list(a = "1", b = "2")), "--- a\n1\n--- b\n2")
})

test_that("a fingerprint is 12 hex characters and depends on the text", {
  expect_match(hash_text("a"), "^[0-9a-f]{12}$")
  expect_false(hash_text("a") == hash_text("b"))
})
