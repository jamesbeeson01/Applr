# Defunct: use geom_slice() instead

`geom_fit()` was removed in favor of
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md),
which does everything it did (prediction lines from a fitted
[`lm()`](https://rdrr.io/r/stats/lm.html), confidence/prediction
ribbons, back-transformation) plus grouping, faceting, and held-variable
reporting. Calling it is an error that points to the replacement.

## Usage

``` r
geom_fit(...)
```

## Arguments

- ...:

  Ignored; accepted only so old calls reach the error message.

## See also

[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
