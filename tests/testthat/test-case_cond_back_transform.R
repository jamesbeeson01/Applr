# CASE: cond_back_transform
# What each engine says about a transformed response: geom_slice() announces
# the back-transformation and warns when it can't do one; slice_2d() is
# silent, except for an unformatted message when no inverse exists.

on_mpg <- function(model, y = quote(mpg), ...) function() {
  ggplot2::ggplot(mtcars, ggplot2::aes(disp, !!y)) + geom_slice(model, ...)
}
base_slice <- function(...) function() {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  slice_2d(..., caption = FALSE)
}

covers("shared.back-transform.message", "shared.back-transform.y-mismatch",
       "shared.back-transform.no-inverse", "shared.back-transform.identity-wrapper",
       "shared.back-transform.engines-differ")

raises("back_transformed", on_mpg(lm(log(mpg) ~ disp, mtcars)), "message",
       "were back-transformed to match the `mpg` axis")
raises("back_transform_off", on_mpg(lm(log(mpg) ~ disp, mtcars), back_transform = FALSE), character())
raises("y_axis_not_response", on_mpg(lm(mpg ~ disp, mtcars), quote(hp)), "warning",
       "does not match the model's response")
raises("no_inverse", on_mpg(lm(abs(mpg) ~ disp, mtcars)), "warning",
       "Could not infer the inverse of the model's response `abs(mpg)`")
raises("identity_wrapper", on_mpg(lm(I(1 / mpg) ~ disp, mtcars)), "warning",
       "Could not infer the inverse")
raises("slice_2d_back_transformed", base_slice(lm(log(mpg) ~ disp, mtcars)), "message",
       "X-axis not specified")
raises("slice_2d_no_inverse", base_slice(lm(abs(mpg) ~ disp, mtcars), x_axis = "disp"), "message",
       "Error creating inverse", format = FALSE)
