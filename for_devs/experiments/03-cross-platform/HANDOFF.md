# Handoff: ticket 03 cross-platform experiment (2026-10-16)

Stopped mid-ticket on request: another session deleted the old suite, including the `tests/cases/` files 13 of the experiment's outputs come from. Status: **in progress**.

## Runs

All runs are on the fork `jamesbeeson01/Applr`, branch `test-suite-revision`, workflow `xplat-experiment`.

| Run | Commit | Outcome |
|---|---|---|
| 38852800081 | 8befae9 | Failed at install on all 3 OSes. The committed project `.Rprofile` (`require(devtools)`) shadows the user profile where setup-r sets the CRAN mirror: "trying to use CRAN without setting a mirror". |
| 38853047587 | 0ef9207 | Failed at install on all 3 OSes, but every package had in fact installed at its pinned version. The version check compared strings, and `packageVersion()` writes `0.1-6` as `0.1.6` (base64enc, RColorBrewer). |
| 38853532374 | b15741d | Succeeded on all 3 OSes. But `tests/cases/` was already gone, so the 13 case outputs are ERROR rows ("cannot open the connection"). |

**Commit 0ef9207's message is incomplete.** It says "Drop project .Rprofile on experiment runners", but it also swept in another session's staged deletion of the whole old suite: 501 files, about 89k lines. It is pushed and left as it is. The old suite survives in the local, unpushed tag `old-suite`, which points at 6cea215.

The results in `results/` are from local-windows (run before the deletion, with all 13 cases) and the three artifacts of run 38853532374. `results/comparison.md` is compare.R's output. Its rows for static ggplot, base graphics and condition text are **meaningless**: on CI those outputs are missing or are ERROR rows.

Environments: R 4.5.3 everywhere, and all 82 pinned packages verified identical on all four platforms.
- local-windows: Windows 11 x64.
- gha-windows: Windows Server 2022 x64. local-windows and gha-windows both use R's reference BLAS with LAPACK 3.12.1.
- gha-macos: macOS 26 on arm64, R's own BLAS and LAPACK 3.12.1.
- gha-ubuntu: Ubuntu 24.04 x86_64, OpenBLAS 0.3.26 with LAPACK 3.12.0.

## Valid results: plotly, slider, animation

Reference: local-windows. "match" means the whole fingerprint is identical.

| Output | gha-windows | gha-macos | gha-ubuntu |
|---|---|---|---|
| `scatter_3d` plotly JSON | match | match | **no match**: 1 line of 113 in `figure` |
| P5 slider demo A | match | match | **no match**: `payload` part only |
| P5 slider demo B | match | match | **no match**: `payload` part only |
| `hp` sweep animation | match | match | match |

Causes of the mismatches:
- **plotly, Ubuntu.** One colorscale stop is `"0.0833333333333333"` locally and `"0.0833333333333334"` on Ubuntu, which is 2/24 differing in the last bit. plotly stores colorscale stops as **strings**, so canonical JSON's `signif(x, 6)` never reaches them. Every numeric array (x, y, z, surface) matched.
- **P5 slider, Ubuntu.** The P5 payload as shipped holds curve coordinates in svglite points, measured from panel boxes that svglite lays out with **system font metrics**. On Ubuntu the panel starts at x0 = 32.78 instead of 33.13, so every mapped coordinate moves. 906 of 2112 lines differ in demo A, and 85 of 436 in demo B. The same curves in data units (`data_payload`), the vdiffr `background`, and the `shell` all matched on every platform.

What these say about the hypotheses:
- **H6, JSON.** It holds for numbers. Canonical JSON matched for every numeric array in all four outputs. It fails in two places the hypothesis didn't foresee:
  - numbers that plotly stringifies, which need their own normalisation rule;
  - payloads that bake in device coordinates. P5 does this. The spec's payload definition already avoids it, because the spec's payload is in data units.
- **H2, floating point.** Confirmed as a real effect, and seen only on Ubuntu (OpenBLAS / LAPACK 3.12.0). Rounding to 6 significant figures absorbed it everywhere except in the string field above. No rounding-boundary flips were seen in numeric fields. Sample: 3 JSON outputs, about 10k numbers.
- **H7, versions not platforms.** Versions were identical everywhere, so every mismatch above is a platform effect. All of them are on Ubuntu. gha-windows and gha-macos matched local-windows exactly.

## Not yet tested: needs the 13 old cases

Outputs: gs_09, gs_17, gs_33, gt_15, sb_15, cp_03, as_23, s2_14, gs_37, gs_53, as_16, gt_17, s2_22. These are 7 static ggplot, 2 base graphics and 11 condition-text outputs. The reason is the same for all of them: `tests/cases/` is not on b15741d, so CI recorded ERROR rows.

- **H1, static and base SVG:** NOT YET TESTED. Incidental, not counted as evidence: 3 vdiffr ggplot SVGs from non-case outputs matched on all 4 platforms. Those are the two slider backgrounds and the animation's `style`.
- **H3, negative zero:** NOT YET TESTED where it depends on the cases. No sign flips appeared in the outputs that did run.
- **H4, text wrap:** NOT YET TESTED. Incidental: demo B's background and the animation's `style` both carry a `geom_slice_subtitle()` and matched. sb_15 and cp_03, the wrap cases, did not run.
- **H5, condition wording:** NOT YET TESTED. CI produced no condition outputs.
- **H2 for SVG** (two-decimal rounding): NOT YET TESTED.

## Half-done and next steps

- **Not done in ticket 03:**
  - the output-type coverage on CI;
  - a complete results table;
  - updating the spec's two deferred decisions and getting them approved.
  - The spec is untouched. It has another session's uncommitted edits.
- **Unpushed or local only:**
  - `results/*/forms/` is gitignored and large. The CI forms are in the run's artifacts, which expire after 90 days.
  - The local-windows forms exist only on this machine.
- **Next steps I would take:**
  1. Restore the 13 cases. The other session decides how; the experiment reads `tests/cases/<id>.R`. Then re-run with `workflow_dispatch` or a push, and run `compare.R`.
  2. Make `fingerprint_all.R` stop when a case file is missing, instead of recording an ERROR output that can "match".
  3. Decide the plotly string fix. Either round numeric-looking strings in canonical JSON, or round colorscale stops specifically. Then re-check Ubuntu.
  4. Draft the two deferred decisions. A provisional reading, pending the cases: Windows and macOS fingerprints agree with the maintainer's machine, and Ubuntu differs only where a normalisation gap exists. So local fingerprints look authoritative across platforms once that gap is closed. Get approval.
- **Cosmetic:** `compare.R` shows a whole file as differing when only the line endings differ (local forms are CRLF). The hashes are unaffected. Read the forms with `diff --strip-trailing-cr`.
- The last commit is marked `[skip ci]` so it doesn't start a run that would repeat the ERROR rows.
