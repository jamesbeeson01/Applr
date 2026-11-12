# CASE: cond_companions
# Conditions from geom_slice_text(), geom_slice_subtitle() and
# geom_slice_caption(): their arguments, no slice to describe, different
# models, labels too wide, and shortened factor names.

model <- lm(mpg ~ wt + hp, data = mtcars)
other <- lm(mpg ~ wt + qsec, data = mtcars)
base <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg))
two_models <- function(companion) function() {
  base + geom_slice(model, predict_vars = list(hp = 100)) +
    geom_slice(other, predict_vars = list(qsec = 18)) + companion()
}

covers("geom_slice_text.arg-validation", "geom_slice_subtitle.arg-validation",
       "shared.companions.no-slice-layer", "shared.companions.different-models",
       "geom_slice_text.too-wide", "shared.annotation-wrap.brackets-message",
       "shared.annotation-wrap.invalid-style")

raises("text_style", function() geom_slice_text(style = "fancy"), "error", "`style` must be one of")
raises("text_location", function() geom_slice_text(location = "top"), "error",
       '`location` must be "right" or "left".')
raises("text_offset", function() geom_slice_text(offset = "5pt"), "error", "`offset` must be a single number")
raises("text_expand", function() geom_slice_text(expand = NA), "error", "`expand` must be TRUE or FALSE.")
raises("subtitle_model", function() geom_slice_subtitle(model = "yes"), "error", "`model` must be TRUE or FALSE.")
raises("subtitle_prepend", function() geom_slice_subtitle(prepend = 1), "error", "`prepend` must be a single string.")
raises("subtitle_append", function() geom_slice_caption(append = c("a", "b")), "error",
       "`append` must be a single string.")
raises("subtitle_wrap", function() geom_slice_subtitle(wrap = -1), "error", "`wrap` must be TRUE, FALSE")
raises("text_no_slice", function() base + ggplot2::geom_point() + geom_slice_text(), "warning",
       "geom_slice_text() found no geom_slice() layer")
raises("subtitle_no_slice", function() base + geom_slice_subtitle(), "warning",
       "geom_slice_subtitle() found no geom_slice() layer")
raises("caption_no_slice", function() base + geom_slice_caption(), "warning",
       "so no caption was added")
raises("text_two_models", two_models(geom_slice_text), "warning", "different models (`model`, `other`)")
raises("subtitle_two_models", two_models(geom_slice_subtitle), "warning", "so no subtitle was added")
raises("text_too_wide", function() {
  d <- data.frame(x = 1:10, y = c(2, 4, 3, 6, 5, 8, 7, 9, 11, 10),
                  a_long_variable_name_for_labels = c(1, 3, 2, 5, 4, 7, 6, 8, 10, 9))
  m <- lm(y ~ x + a_long_variable_name_for_labels, d)
  ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    geom_slice(m, predict_vars = list(a_long_variable_name_for_labels = c(1.23456, 98765.4321))) +
    geom_slice_text(offset = 400)
}, "warning", "cannot fit its labels")
raises("brackets_used", function() {
  m <- lm(Sepal.Length ~ Sepal.Width * Species + Petal.Length, iris)
  ggplot2::ggplot(iris, ggplot2::aes(Petal.Length, Sepal.Length, colour = Species)) +
    geom_slice(m) + geom_slice_subtitle(wrap = 3.5)
}, c("message", "message"), "Factor terms were shortened to fit the subtitle")
raises("subtitle_bad_style", function() {
  base + geom_slice(model, predict_vars = list(hp = 100)) + geom_slice_subtitle(style = "fancy")
}, "warning", '`style` must be one of "prettier", "brackets", "raw"')
