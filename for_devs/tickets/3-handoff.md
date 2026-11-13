# Handoff: ticket 3, done

**Status (2026-11-13):** Ticket 3 is done. The maintainer approved the two CI decisions in chat on 2026-11-13. Ticket 4 is next.

Read first: `3-ci-and-release-check.md` (the ticket), the spec's *CI* section, and `tests/suite/README.md` (*CI and the release check*).

## What was built

| What | Where |
|---|---|
| The CI check: runs every case, fingerprints without writing state, reports by the approved policy, bundles platform variants, writes GitHub annotations and a summary | `tests/suite/ci.R`, logic in `tests/suite/check.R` |
| The workflow, on Windows, macOS and Ubuntu, fork only | `.github/workflows/judged-outputs.yaml` |
| Pinned versions, moved from the experiment | `tests/suite/pins/` |
| Agent approval of a platform variant from a CI bundle | `suite.R variant <bundle> <id> "<note>"` |
| The release check and audit | `tests/suite/release.R` |
| Unit tests for all of it; seven new mutation breaks | `tests/suite/unit/test-check.R`, `mutate.R` |

The experiment folder and its `xplat-experiment` workflow are deleted. The results are in the spec.

## Results

- All 143 judged outputs match the maintainer's machine on all three runners (runs 43353432226, 43354217559). H1, H2, H4, H5, H6 and H7 are confirmed; H3 showed no mismatch. Details in the spec.
- The `judged-outputs` workflow's first run (43367755333) passes on all three platforms: 143 warnings each, since everything is Agent approved. Nothing fails, and there are no variants.
- `num_companions` failed on macOS because `grDevices::svg()` needs cairo. It now checks the display list instead.
- `R CMD check --as-cran` runs the expectations in 34 seconds, single-threaded (618 pass).

## Gotchas

- The release check can't pass yet: no output is Human approved, so the audit has no approval screenshots to compare against. Those are kept in the gitignored `tests/output/approved/` when the maintainer approves in the page, so the release check only works on that machine.
- Nothing yet runs `release.R` automatically before a submission. It's a script to run by hand before `devtools::submit_cran()`.
- The review page doesn't show platform variants yet. They're only in `review_state.json` under `variants`.
- The mutation check's unbroken copy failed `plotly_3d: completeness` until `screenshot_session()` (`views.R`) learned to retry. Two copies starting Chrome at the same moment left one with "Chrome debugging port not open after 60 seconds"; it now retries once with a fresh Chrome. `mutate.R` now also prints the unbroken copy's test log when it fails, and the contract test names the runner's "views failed" message.
- ubuntu-latest is now Ubuntu 26.04. In the first run, its RSPM download of `pak` failed once with an SSL error; a re-run fixed it.
