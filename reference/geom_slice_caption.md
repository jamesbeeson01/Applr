# Describe the lines drawn by geom_slice() in the plot caption

`geom_slice_caption()` is
[`geom_slice_subtitle()`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md)
for the plot caption: it fills the caption (right-aligned in ggplot2's
default themes) with the model equation and the held values the plot
does not otherwise show. All behavior — what is reported, what is
skipped because the legend, facets, or
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)
already label it, and every parameter — matches
[`geom_slice_subtitle()`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md);
see its documentation for the details.

## Usage

``` r
geom_slice_caption(model = TRUE, prepend = "", append = "", format = NULL)
```

## Arguments

- model:

  If `TRUE` (default), the subtitle's first line is the model equation;
  `FALSE` drops it, leaving only the held-values line.

- prepend, append:

  Plain strings pasted before the first line and after the last line of
  the default subtitle.

- format:

  A function of `(equation, values)` — the ready-made equation string
  and the named list of unlabeled held values — returning the whole
  subtitle. When given, it fully replaces the default layout (`model`,
  `prepend`, and `append` are ignored).

## Value

An object that sets the plot caption when added to a ggplot.

## See also

[`geom_slice_subtitle()`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md)
for the full documentation of what is reported;
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
for the layers being described;
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)
to label the lines themselves.

## Examples

``` r
library(ggplot2)

# Caption reports the model equation and that hp is held at its mean
model <- lm(mpg ~ disp + hp, data = mtcars)
ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model) +
  geom_slice_caption()
#> Value for `hp` not specified - Used mean: 146.7
#>     To choose a slice, use 'predict_vars = list(hp = 146.7)'.

```
