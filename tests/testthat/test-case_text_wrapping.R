# CASE: text_wrapping
# The same long subtitle wrapped to fixed widths, so the result doesn't
# depend on the device: how it breaks, indents and shortens factor names.

iris_model <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, data = iris)
on_iris <- function(...) {
  suppressMessages(ggplot2::ggplot(iris, ggplot2::aes(Petal.Length, Sepal.Length, colour = Species)) +
                     geom_slice(iris_model) + geom_slice_subtitle(...))
}
shared_level <- data.frame(
  x = rep(1:6, 2), a = factor(rep(c("Low", "High"), 6), levels = c("Low", "High")),
  b = factor(rep(c("Mid", "Mid", "High"), 4), levels = c("Mid", "High")),
  y = c(2, 5, 4, 8, 6, 9, 3, 6, 5, 9, 7, 11)
)
ambiguous <- lm(y ~ x + a + b, data = shared_level)

examples <- c(
  unwrapped = annotation_of(on_iris(wrap = FALSE)),
  wide_6in = annotation_of(on_iris(wrap = 6)),
  brackets_3.5in = annotation_of(on_iris(wrap = 3.5)),
  narrow_2in = annotation_of(on_iris(wrap = 2)),
  prepend_4in = annotation_of(on_iris(wrap = 4, prepend = "Fitted: ")),
  overlong_1in = annotation_of(on_iris(wrap = 1, model = TRUE)),
  shared_level_1.5in = annotation_of(suppressMessages(
    ggplot2::ggplot(shared_level, ggplot2::aes(x, y)) + geom_slice(ambiguous) + geom_slice_subtitle(wrap = 1.5)))
)

covers("shared.annotation-wrap.fits", "shared.annotation-wrap.between-terms",
       "shared.annotation-wrap.ladder", "shared.annotation-wrap.width-or-off",
       "shared.annotation-wrap.prepend-equals", "shared.annotation-wrap.overlong-term",
       "shared.annotation-wrap.ambiguous-brackets")
judged_output("wrapped", examples, type = "returned_text")

lines <- function(name) strsplit(examples[[name]], "\n", fixed = TRUE)[[1]]
blank <- "^[    ]+"

test_that("wrap = FALSE keeps one line per item; a width breaks between terms only", {
  expect_length(lines("unwrapped"), 2)
  wrapped <- lines("wide_6in")
  expect_gt(length(wrapped), 2)
  rejoined <- paste(sub(blank, "", wrapped[-length(wrapped)]), collapse = " ")
  expect_equal(rejoined, lines("unwrapped")[1])
  expect_false(any(grepl("[+-]$", wrapped)))
})

test_that("continuation lines hang under the equation's right-hand side, even after a prefix", {
  wrapped <- lines("wide_6in")
  expect_true(all(grepl(blank, wrapped[2:(length(wrapped) - 1)])))
  pre <- lines("prepend_4in")
  expect_match(pre[1], "^Fitted: Sepal.Length = ")
  expect_true(grepl(blank, pre[2]))
})

test_that("the short [level] form appears only where it buys a fit, and never when ambiguous", {
  expect_false(grepl("[", examples[["wide_6in"]], fixed = TRUE))
  expect_true(grepl("[virginica]", examples[["brackets_3.5in"]], fixed = TRUE))
  expect_false(grepl("[High]", examples[["shared_level_1.5in"]], fixed = TRUE))
})

test_that("a term wider than the line sits on a line of its own", {
  over <- lines("overlong_1in")
  expect_true('- 0.286*Sepal.Width:(Species="virginica")' %in% over)
})

test_that("a single held value splits between its name and value today (known issue)", {
  # KNOWN ISSUE (for_devs/known_issues.Rmd): with one held value the line is
  # broken at any space, so "Sepal.Width = 3.057" can split. When this
  # fails, the pair stays together.
  over <- lines("overlong_1in")
  expect_equal(utils::tail(over, 2), c("held at: Sepal.Width", "= 3.057"))
})
