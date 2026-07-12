# Handoff: console-output capture for visual test cases

Date: 2026-07-11 · Branch: `feature/align-geom_slice`

## Why this change was made

Visual cases previously produced only a PNG. Any message or warning a case
emitted (e.g. gs_02's `Value for 'x_pos' not specified - Used mean: 4.77`)
leaked to the terminal and was never asserted anywhere — a case could start
emitting a wrong message, or a strange warning, and still report `OK`.
Console cases had the mirror problem (plots discarded), but that side was
already acceptable; the gap was on the visual side.

We considered duplicating cases (one visual + one console twin per scenario)
and rejected it: everything renders twice, the twins can drift, and
visual-only cases would still pass while emitting garbage.

## What changed

All changes are in `testing/run.R` (plus docs in `testing/README.md`).
No case files were modified.

`run_visual()` now wraps case execution in `sink()` for both stdout and the
message stream (with `options(warn = 1)` so warnings print immediately,
inside the sink). Whatever the case prints lands in
`testing/output/<id>.txt` and is checked against
`testing/expected/<id>.txt` with the same diff used for console cases
(`diff_lines()`, now shared by both runners):

| Situation | Result |
|---|---|
| No snapshot, case silent | `OK` (no `.txt` kept) |
| No snapshot, case prints something | `NEW` — review, then `--update` or fix |
| Snapshot exists, output matches | `OK` |
| Snapshot exists, output differs | `FAIL` (console diff shown) |
| Snapshot exists, case now silent | `FAIL` |
| `--update` | writes the snapshot; deletes it if the case went silent |

Key invariant: **a visual case with no `expected/<id>.txt` is asserted to be
silent.** So an unexpected warning on any visual case is now surfaced instead
of ignored. The PNG check (ran + produced exactly one plot) is unchanged, as
is `run_console()` behavior and `report.Rmd` (which shells out to `run.R`, so
it inherits all of this; it already displays messages/warnings inline).

## Verification done

All paths exercised on real cases: gs_02 reported `NEW` with its imputation
message captured verbatim; `--update` snapshotted it and it now reports `OK`;
a corrupted snapshot produced the line-level `FAIL` diff; a snapshot planted
on silent gs_01 produced the "expected console output but the case printed
nothing" `FAIL`. `testing/expected/gs_02_additive_default_held.txt` was kept
as the first real visual snapshot.

## Current suite state (full run after the change)

165 cases: **113 OK, 47 NEW, 5 FAIL.**

The 5 FAILs are pre-existing, unrelated to this change: `dw_03`, `dw_05`,
`s2_03`, `s2_06` are documented `KNOWN ISSUE` cases; `gs_38` fails at plot
build (continuous variable mapped to linetype).

The 47 NEW are visual cases that were already emitting console output —
previously invisible, now flagged:

- `ap_`: 02, 03, 05
- `as_`: 01–11 (all happy-path add_slice_2d cases)
- `dw_`: 04, 06
- `gs_`: 09, 10, 11, 12, 16, 17, 18, 39, 44, 45, 50, 52
- `s2_`: 01, 02, 04, 05, 07–14 (all happy-path slice_2d cases)
- `sb_`: 01, 03, 04, 05, 06, 07, 09

Their captured output is sitting in `testing/output/<id>.txt` right now.

## What the analysis needs to do (your task)

For **each** NEW case, read `testing/output/<id>.txt` and decide, one of:

1. **The output is intentional and correct** (e.g. the documented
   held-value/imputation message, in the right format, with plausible
   numbers) → snapshot it: `Rscript testing/run.R --update <id>`.
2. **The output is intentional but the case's `# EXPECT:` header doesn't
   mention it** → snapshot it AND extend the EXPECT header so the report
   describes the message too. Watch especially for headers that say
   "No errors or warnings" on cases that do message — decide which side is
   wrong.
3. **The output is a symptom** — a warning nobody intended, a message with
   wrong content, a stray printed value → do NOT snapshot. File/fix the
   underlying issue in `R/` (or fix the case if the case is misusing the
   API), then re-run until the case is silent or its output is correct.

Judgment guidance:

- The `as_*` and `s2_*` families message on nearly every happy-path case —
  check whether that's the same held-value message as gs_02 (likely fine,
  category 1/2) or console chatter from base-graphics code paths that should
  arguably be quieter (category 3 → discuss before changing API behavior).
- Numbers inside snapshotted messages (means, held values) are locked in by
  the snapshot. That's intended — each case owns its seed, so they're
  deterministic. If a message prints something non-deterministic
  (timestamps, environments, addresses), that's a category-3 problem.
- Batch review is fine, but `--update` accepts whatever is on disk — never
  run a blanket `--update` across all NEW cases without reading each txt.
- When done: full run should show 0 NEW, the same 5 pre-existing FAILs (or
  fewer), and then render the report:
  `Rscript -e "rmarkdown::render('testing/report.Rmd')"`.

See `testing/README.md` ("Running tests" section) for the updated rules.
