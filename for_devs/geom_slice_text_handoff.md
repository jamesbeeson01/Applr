# geom_slice_text() — design handoff

Context for whoever implements `geom_slice_text()`. The feature is fully
specified by the `gt_*` test cases (`testing/cases/gt_01`–`gt_12`) and their
rendered references (`testing/reference/gt_*.png`); this file records the
*decisions behind them* and the implementation traps we already identified.
The general test workflow is in `CLAUDE.md` / `testing/README.md` — not
repeated here.

## What it is

End-of-line text labels for `geom_slice()` lines. Motivation: multi-value
`predict_vars` (e.g. `list(x2 = c(0, 2, 4), x3 = c(0, 1))`) draws visually
identical lines with nothing distinguishing them — deliberately, since
geom_slice imposes no styling. Labels fix that, and double as a legend
replacement for aesthetic groupings.

## Locked-in interface (owner-approved; don't renegotiate)

```r
geom_slice_text(style = "variable",   # "variable" | "value" | "legend"
                location = "right",   # "right" | "left" end of line
                offset = 5,           # gap in POINTS, line end -> label edge
                hjust = NULL,         # NULL = auto; manual DISABLES offset
                vjust = NULL,
                color = NULL,         # NULL = inherit the line's color
                expand = TRUE)        # auto x-range widening on/off
```

**No `model`, no `predict_vars` argument.** It borrows everything from the
plot's existing `geom_slice()` layers (decision made explicitly after a first
draft duplicated those arguments — the owner rejected the duplication).

- `style = "variable"` (default): `"x2: 0"`; multiple vars joined with `"; "`
  → `"x2: 0; x3: 1"`. Order matches `predict_vars` order.
- `style = "value"`: bare `"0"`, or `"0; 1"`.
- `style = "legend"`: bare values at line ends **plus** a corner key in the
  panel's top-right reading `labels: x2; x3` (semicolon, mirroring the label
  separator — the owner originally suggested a comma; I chose `;` so the key
  reads as a template for the labels; flag it if they push back). Key color =
  the line color when all lines share one color, gray/black when lines are
  multi-colored (the multi-color branch has no test case yet).
- Labels also come from grouping aesthetics: with `aes(color = g)` and no
  multi-value predict_vars, labels are `"g: A"`, `"g: B"` (gt_09). With both
  (gt_07), the predict_vars label is shown and color comes from the group.

## Decisions that are easy to get wrong

**Offset is in points, not hjust, not data units.** `hjust = -0.15` was the
first draft and produced visibly different gaps per label (hjust is measured
in label widths). Data-unit nudges change meaning with the axis range. The
spec: anchor at the line end with `hjust = 0` (for `location = "right"`;
`hjust = 1` for left), then displace by `offset` points at **draw time in
grid units** — like axis tick label margins. Constant gap regardless of
label text, axis range, plot size. If the user passes `hjust` themselves,
the auto-offset is disabled entirely (gt_06 relies on this).

**The geom manages its own margin.** Cases contain **no**
`scale_x_continuous(expand = ...)` — `expand = TRUE` must widen the x-range
on the label side only, scaled by the longest label. The references emulate
this with `mult = 0.025 + 0.013 * nchar(longest_label)` (and `location =
"left"` moves the expansion to the lower side — see gt_05's reference).
`style = "legend"` additionally adds y-headroom (~`mult = 0.1` upper) so the
corner key clears the topmost line's label (gt_04's reference). `expand =
FALSE` turns all of it off. Note a layer cannot alter scales — see the
mechanism below.

**References approximate the offset.** `geom_text` can't do pt-offsets, so
reference plots use `hjust = 0/1` + `nudge_x = ±0.012 * diff(range(dat$x))`.
At 7×5 in that is visually ≈ 5 pt. When comparing output to reference, judge
"small constant gap", not pixel equality of the gap.

## Implementation route (worked out, not yet built)

`geom_slice_text()` should NOT return a plain layer. Return an object with a
`ggplot_add` method (the codebase precedent is `ggplot_add.SliceLayer` in
`R/geom_slice.R`, which exists because add-time is the first moment the plot
is in hand). At add time:

1. Scan `plot$layers` for layers whose class is `SliceLayer` (or whose stat
   params carry a model — they store `model`, `model_name`, `predict_vars`
   in `stat_params`; see the `layer(params = list(...))` call at the bottom
   of `R/geom_slice.R`).
2. **Zero slice layers → warning** (gt_11), add nothing. This also covers
   the ordering constraint: `geom_slice_text()` added *before* the
   `geom_slice` calls sees no layers — that's fine, same warning.
3. **Two+ layers, different models (`!identical()`) → warning** (gt_12).
   Multiple layers of the *same* model must be merged as if their
   predict_vars were combined: `geom_slice(m, list(x2 = 0), color = "blue") +
   geom_slice(m, list(x2 = 1), color = "red") + geom_slice_text()` labels
   both lines, each label inheriting its own layer's color (gt_10).
4. Because `ggplot_add` receives the whole plot, this is also where
   `expand = TRUE` can add the scale expansion — a layer alone never could.
   Sizing it needs the label strings, which are computable at add time from
   the models' predict_vars/grouping vars.

Other backend facts you'd otherwise rediscover slowly:

- Line endpoints aren't known until after StatSlice runs. The text layer
  must compute the same slices (same spec resolution) or share StatSlice's
  computation; each line's endpoint is the max-x (or min-x) point of its
  group. Multi-value combos get distinct group ids via the
  `data$group[1] * nrow(combos) + (i - 1)` scheme in `compute_slice_group()`
  — label/combo pairing must use the same ordering (`expand.grid` over
  `spec$held`).
- "Inherit the line's color": for default-styled slices that's GeomSlice's
  default `"skyblue"`; for fixed params (`color = "blue"`) it's in the
  layer's `aes_params`; for mapped aesthetics (gt_07/gt_09) the text layer
  should map the same aesthetic and suppress its legend contribution.
  Warning/message helpers are `slice_warn()`/`slice_inform()`/`slice_abort()`
  (grep R/ — used everywhere; messages follow a what + hint pattern with
  copy-pasteable hints).
- Imputation messages: geom_slice's `impute_value()` messages once per
  layer. If geom_slice_text re-resolves the spec, guard against the user
  seeing every imputation message twice.

## Test-suite state

- gt_01–gt_10 are visual, each with a rendered reference PNG; gt_11/gt_12
  are console cases with **no `expected/` snapshots yet** — run them after
  implementing, review the output, then `run.R --update gt_11 gt_12`.
- `testing/reference/build_all.R`'s glob was widened to `^(gs|gt)_`.
- All cases currently FAIL (function doesn't exist). That's the intended
  starting state.
- The reference expansion/nudge constants (`0.012`, `0.025 + 0.013 * nchar`)
  are the emulation, not the spec — the spec is "constant pt gap" and
  "margin fits the longest label snugly". If the implementation's constants
  differ slightly, adjust the references to match the implementation rather
  than contorting the implementation, as long as the two visual goals hold.
