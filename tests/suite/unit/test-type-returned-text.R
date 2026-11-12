test_that("entries keep their order, with names as headers and a blank line between", {
  expect_equal(text_form(c(a = "one", b = "two\nthree")), c("[a]", "one", "", "[b]", "two", "three"))
  expect_equal(text_form(c("x", "y")), c("x", "", "y"))
  expect_equal(text_form(character()), "(no text)")
})

test_that("a character vector is claimed as text without declaring it", {
  expect_equal(resolve_output_type(list(object = "y = 1 + 2*x"))$name, "returned_text")
})
