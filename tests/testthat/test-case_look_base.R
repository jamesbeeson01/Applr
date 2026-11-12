# CASE: look_base
# Base graphics: slice_2d()'s plot, title, axis labels and caption, a styled
# line with its band, overlaid add_slice_2d() slices, and diagnose()'s
# three panels.

logged <- lm(log(mpg) ~ disp + hp, data = mtcars)
quietly <- function(code) function() suppressMessages(code())

covers("slice_2d.plot-labels", "slice_2d.ylim-covers-band", "slice_2d.graphical-params",
       "add_slice_2d.adds-to-plot", "add_slice_2d.caption-off", "diagnose.three-panels")
judged_output("slice_2d_default", quietly(function() slice_2d(logged)), type = "base_graphics")
judged_output("slice_2d_styled", quietly(function() {
  slice_2d(logged, x_axis = "hp", disp = 250, n = 150, col = "blue", lwd = 2, interval = "prediction")
}), type = "base_graphics")
judged_output("add_slice_2d_overlay", quietly(function() {
  plot(mpg ~ disp, data = mtcars)
  add_slice_2d(logged, hp = min(mtcars$hp), col = "blue")
  add_slice_2d(logged, hp = max(mtcars$hp), col = "red", lty = 2, interval = "confidence")
}), type = "base_graphics")
judged_output("diagnose", function() diagnose(lm(dist ~ speed, data = cars)), type = "base_graphics")

test_that("with an interval the y-axis covers the band", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  suppressMessages(slice_2d(logged, x_axis = "hp", disp = 250, interval = "prediction"))
  prep <- prepare_slice_data(logged, "hp", 100, TRUE, "prediction", list(disp = 250))
  usr <- graphics::par("usr")
  expect_lte(usr[3], min(prep$line$lwr))
  expect_gte(usr[4], max(prep$line$upr))
})
