# CASE: num_band
# A projection band's edges are the predictions at the banded variable's two
# values, which come from predict_vars, the data range, or band = TRUE.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ * drv + cyl, data = mpg)
coloured <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv))

covers("shared.band.edges-are-predictions", "shared.band.range", "shared.band.infer-true",
       "geom_slice_text.band-edges")

edges <- function(line, drv, lo, hi) {
  a <- predicted(model, data.frame(displ = line$x, drv = drv, cyl = lo))
  b <- predicted(model, data.frame(displ = line$x, drv = drv, cyl = hi))
  list(ymin = pmin(a, b), ymax = pmax(a, b), y = (a + b) / 2)
}

test_that("a named band spans the predict_vars values, with the line at the midpoint", {
  d <- slice_data(coloured + geom_slice(model, n = 10, band = "cyl", predict_vars = list(cyl = c(7, 5))))
  lv <- levels(factor(mpg$drv))
  for (g in unique(d$group)) {
    line <- d[d$group == g, ]
    e <- edges(line, lv[g], 5, 7)
    expect_equal(line$ymin, e$ymin)
    expect_equal(line$ymax, e$ymax)
    expect_equal(line$y, e$y)
  }
})

test_that("without predict_vars the band spans the data range, and band = TRUE finds cyl", {
  named <- slice_data(coloured + geom_slice(model, n = 10, band = "cyl"))
  inferred <- slice_data(coloured + geom_slice(model, n = 10, band = TRUE))
  expect_equal(inferred, named)
  e <- edges(named[named$group == 1, ], "4", min(mpg$cyl), max(mpg$cyl))
  expect_equal(named$ymin[named$group == 1], e$ymin)
})

test_that("band = TRUE picks the one multi-value predict_vars entry", {
  m <- lm(hwy ~ displ + cyl + year, data = mpg)
  d <- slice_data(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy)) +
                    geom_slice(m, n = 10, band = TRUE, predict_vars = list(year = c(1999, 2008), cyl = 6)))
  a <- predicted(m, data.frame(displ = d$x, cyl = 6, year = 1999))
  b <- predicted(m, data.frame(displ = d$x, cyl = 6, year = 2008))
  expect_equal(d$ymin, pmin(a, b))
  expect_equal(d$ymax, pmax(a, b))
})

test_that("geom_slice_text() labels each edge with the value that made it", {
  p <- suppressMessages(coloured + geom_slice(model, band = "cyl", predict_vars = list(cyl = c(5, 7))) +
                          geom_slice_text())
  t <- slice_text_data(p)
  expect_equal(sort(unique(t$label)), c("cyl: 5", "cyl: 7"))
  for (i in seq_len(nrow(t))) {
    cyl <- as.numeric(sub("cyl: ", "", t$label[i]))
    drv <- levels(factor(mpg$drv))[t$colour[i] == unique(t$colour)]
    expect_equal(t$y[i], predicted(model, data.frame(displ = t$x[i], drv = drv, cyl = cyl)))
  }
})
