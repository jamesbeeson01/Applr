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

test_that("a single-part output has no header; every part of a multi-part one is hashed", {
  expect_equal(fingerprint_output(list(parts = list(main = "x")))$form, "x")
  fp <- fingerprint_output(list(parts = list(a = "1", b = "2", c = "3")))
  expect_equal(fp$form, "--- a\n1\n--- b\n2\n--- c\n3")
  expect_named(fp$part_hashes, c("a", "b", "c"))
})

test_that("compute steps run under the pinned options, whatever the session's", {
  withr::local_options(useFancyQuotes = TRUE, cli.unicode = TRUE, digits = 3, OutDec = ",", width = 40)
  seen <- with_pinned_options(options()[names(suite_options)])
  expect_equal(seen, suite_options[names(seen)])
})

test_that("canonical JSON drops classes, sorts keys, rounds numbers and keeps array order", {
  x <- list(b = structure(list(z = 1, a = 2), class = "thing"), a = c(3, 1, 2) / 3)
  expect_equal(canonical_json(x), canonical_json(list(a = c(1, 1 / 3, 2 / 3), b = list(a = 2, z = 1))))
  expect_false(identical(canonical_json(list(a = 1:3)), canonical_json(list(a = 3:1))))
  expect_match(paste(canonical_json(list(v = pi)), collapse = ""), '"v": 3.14159\\}')
})

test_that("canonical JSON rounds decimal strings like numbers and leaves other strings alone", {
  stops <- c("0", "0.0833333333333333", "0.0833333333333334", ".5", "1e-17",
             "12345678901234", "1.5x", "abc")
  out <- canonical_value(list(s = stops))$s
  expect_equal(out, c("0", "0.0833333", "0.0833333", "0.5", "1e-17",
                      "12345678901234", "1.5x", "abc"))
})
