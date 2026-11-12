# CASE: text_subtitles
# Representative geom_slice_subtitle() texts, unwrapped so the wording is
# judged apart from the plot size, plus slice_2d()'s caption.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ * drv + cyl + year, data = mpg)
coloured <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv))
subtitle <- function(p) annotation_of(suppressMessages(p))

examples <- c(
  imputed = subtitle(coloured + geom_slice(model) + geom_slice_subtitle(wrap = FALSE)),
  held_values = subtitle(coloured + geom_slice(model, predict_vars = list(cyl = c(4, 8), year = 2008)) +
                           geom_slice_subtitle(wrap = FALSE)),
  band = subtitle(coloured + geom_slice(model, band = "cyl", predict_vars = list(year = 1999)) +
                    geom_slice_subtitle(wrap = FALSE)),
  no_equation = subtitle(coloured + geom_slice(model) + geom_slice_subtitle(model = FALSE)),
  prepend_append = subtitle(coloured + geom_slice(model) +
                              geom_slice_subtitle(prepend = "Fitted: ", append = " (mpg data)", wrap = FALSE)),
  style_brackets = subtitle(coloured + geom_slice(model) + geom_slice_subtitle(style = "brackets", wrap = FALSE)),
  string_value = subtitle(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy)) +
                            geom_slice(lm(hwy ~ displ + drv, mpg), predict_vars = list(drv = "r")) +
                            geom_slice_subtitle(wrap = FALSE)),
  slice_2d_caption = suppressMessages(prepare_slice_data(model, "displ", 10, TRUE, "none",
                                                         list(drv = "f")))$caption_text,
  slice_2d_caption_empty = prepare_slice_data(lm(hwy ~ displ, mpg), "displ", 10, TRUE, "none", list())$caption_text
)

covers("geom_slice_subtitle.equation-line", "geom_slice_subtitle.held-line",
       "geom_slice_subtitle.band-line", "geom_slice_subtitle.prepend-append",
       "geom_slice_subtitle.dots-to-equation", "slice_2d.caption", "slice_2d.caption-nothing-held")
judged_output("subtitles", examples, type = "returned_text")

lines <- function(name) strsplit(examples[[name]], "\n", fixed = TRUE)[[1]]

test_that("the equation comes first and the held values second, unless dropped", {
  expect_equal(lines("imputed")[1], lm_equation(model))
  expect_equal(lines("imputed")[2], "held at: cyl = 5.889; year = 2004")
  expect_equal(lines("held_values")[2], "held at: cyl = 4, 8; year = 2008")
  expect_equal(examples[["no_equation"]], "held at: cyl = 5.889; year = 2004")
  expect_equal(lines("string_value")[2], 'held at: drv = "r"')
})

test_that("a band gets its own line, and prepend, append and style apply", {
  expect_equal(lines("band")[2:3], c("held at: year = 1999", "projection band: cyl spanning from 4 to 8"))
  expect_match(examples[["prepend_append"]], "^Fitted: hwy = .* \\(mpg data\\)$")
  expect_equal(lines("style_brackets")[1], lm_equation(model, style = "brackets"))
})

test_that("slice_2d()'s caption lists held values to 1 decimal, and is empty with none", {
  expect_equal(examples[["slice_2d_caption"]], "drv: f; cyl: 5.9; year: 2003.5")
  expect_equal(examples[["slice_2d_caption_empty"]], "")
})
