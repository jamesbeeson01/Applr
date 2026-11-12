# CASE: num_slicing
# Grouping aesthetics and facets pin their predictor to each group's or
# panel's own value; a facet the model doesn't use pins nothing.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ * drv + cyl, data = mpg)
cyl_mean <- mean(mpg$cyl)

covers("shared.slicing.group-pins", "shared.slicing.facet-pins",
       "shared.slicing.factor-wrapped-aes", "shared.slicing.facet-not-predictor",
       "autoplot.user-facet-after")

expect_line <- function(line, ...) {
  expect_equal(line$y, predicted(model, data.frame(displ = line$x, ...)))
}

test_that("each colour group is predicted at its own value", {
  d <- slice_data(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) + geom_slice(model, n = 10))
  lv <- levels(factor(mpg$drv))
  for (g in unique(d$group)) expect_line(d[d$group == g, ], drv = lv[g], cyl = cyl_mean)
  d <- slice_data(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, linetype = drv)) + geom_slice(model, n = 10))
  for (g in unique(d$group)) expect_line(d[d$group == g, ], drv = lv[g], cyl = cyl_mean)
})

test_that("each panel is predicted at its own facet value, wrap or grid", {
  lv <- levels(factor(mpg$drv))
  for (facet in list(ggplot2::facet_wrap(~drv), ggplot2::facet_grid(rows = ggplot2::vars(drv)))) {
    d <- slice_data(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy)) + geom_slice(model, n = 10) + facet)
    for (panel in unique(d$PANEL)) {
      expect_line(d[d$PANEL == panel, ], drv = lv[as.integer(panel)], cyl = cyl_mean)
    }
  }
})

test_that("colour = factor(cyl) pins the numeric cyl at each group's number", {
  d <- slice_data(ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = factor(cyl))) +
                    geom_slice(model, n = 10, predict_vars = list(drv = "f")))
  cyls <- sort(unique(mpg$cyl))
  for (g in unique(d$group)) expect_line(d[d$group == g, ], drv = "f", cyl = cyls[g])
})

test_that("a facet on a variable the model doesn't use gives every panel the same line", {
  m <- lm(mpg ~ wt, mtcars)
  d <- slice_data(ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(m, n = 10) +
                    ggplot2::facet_wrap(~gear))
  for (panel in unique(d$PANEL)) {
    line <- d[d$PANEL == panel, ]
    expect_equal(line$y, predicted(m, data.frame(wt = line$x)))
  }
})

test_that("a facet added after autoplot() still pins its predictor for the line", {
  m <- lm(hwy ~ displ + drv + cyl, data = mpg)
  p <- suppressMessages(autoplot(m, ggplot2::aes(colour = factor(cyl)), summary = FALSE)) +
    ggplot2::facet_wrap(~drv)
  d <- slice_data(p)
  lv <- levels(factor(mpg$drv))
  cyls <- sort(unique(mpg$cyl))
  for (k in seq_len(nrow(unique(d[c("PANEL", "group")])))) {
    key <- unique(d[c("PANEL", "group")])[k, ]
    line <- d[d$PANEL == key$PANEL & d$group == key$group, ]
    expect_equal(line$y, predicted(m, data.frame(displ = line$x, drv = lv[as.integer(key$PANEL)],
                                                 cyl = cyls[key$group])))
  }
})
