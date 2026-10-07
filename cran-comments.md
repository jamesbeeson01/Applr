## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

* local: Windows 11, R 4.5.x
* win-builder: R-devel, R-release
* mac-builder: R-release
* GitHub Actions: macOS-latest, windows-latest, ubuntu-latest (R-release, R-devel)

## Notes for reviewers

* `autoplot.lm()` prints `summary()` of the model by default, since the
  function is designed for interactive model exploration. Users can
  suppress it with `summary = FALSE`.
* Examples that create 'plotly' widgets are wrapped in `if (interactive())`.
* Thanks for your work taking time to review this.
