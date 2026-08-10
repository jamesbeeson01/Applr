# dev_todo

- **`slice_defaults(model)`** — named list of the value `geom_slice()` would
  impute for each predictor, in `predict_vars` shape. Answers "what is it
  holding things at?" before a plot exists, and round-trips: inspect it, edit
  one value, pass it back as `predict_vars`. Nothing else exposes this; ~6
  lines over `slice_model_frame()` + `impute_value()`.

## Known issues

- An invalid `style` through `geom_slice_subtitle(...)` warns and falls back to
  `"prettier"`, but `annotation_equation_args()` has already read it as a pinned
  style and dropped the `"brackets"` wrap fallback, so the subtitle can run off
  a narrow plot. Detecting it would put `style` validation back inside the
  annotation, which is what `...` exists to avoid — and the warning names the
  typo, which is the fix.
