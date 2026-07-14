# Describe the lines drawn by geom_slice() in the plot subtitle

`geom_slice_subtitle()` fills the plot subtitle with a description of
the plot's
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
layers: the model equation
([`lm_equation()`](https://saundersg.github.io/Applr/reference/lm_equation.md)
style) on the first line, and the held values the plot does not
otherwise show on the second (`"held at: x2 = 2.507"`, formatted like
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)'s
console messages).

## Usage

``` r
geom_slice_subtitle(model = TRUE, prepend = "", append = "", format = NULL)
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

An object that sets the plot subtitle when added to a ggplot.

## Details

It takes no `model` or `predict_vars` — everything is borrowed from the
plot's existing
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
layers, so add it *after* them (and after any
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)).
The held-values line is conscious of what the plot already labels:
variables labeled by
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md),
pinned by a grouping aesthetic (the legend covers those), or pinned by
faceting are left out. User-chosen `predict_vars` values and imputed
defaults are treated the same — both are unlabeled held values. When
nothing is held, the line is dropped entirely.

## See also

[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
for the layers being described;
[`geom_slice_caption()`](https://saundersg.github.io/Applr/reference/geom_slice_caption.md)
for the same text in the caption;
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)
to label the lines themselves.

## Examples

``` r
library(ggplot2)

# Subtitle reports the model equation and that hp is held at its mean
model <- lm(mpg ~ disp + hp, data = mtcars)
ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model) +
  geom_slice_subtitle()
#> Value for `hp` not specified - Used mean: 146.7
#>     To choose a slice, use 'predict_vars = list(hp = 146.7)'.

```
