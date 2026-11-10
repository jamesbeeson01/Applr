# 3: CI and release check

**What to build:** Finish the cross-platform experiment on the new cases, settle the spec's two deferred decisions from its results, then make GitHub runs on the test-suite branch report review statuses by that policy, and add a release check that blocks a CRAN submission until everything is Human approved.

**Done when:** a results table shows, per output type and platform, whether fingerprints match and why; the maintainer has approved the two decisions in the spec; GitHub runs report each review status by that policy; and the release check fails until every output is Human approved.

**Blocked by:** 2

**Status:** ready-for-agent

## Starting point

Read `for_devs/experiments/03-cross-platform/HANDOFF.md`. The plotly, slider and animation results there are valid, and the spec's *CI* section summarises them. Static ggplot, base graphics and condition text were never tested, because their inputs were old cases, which have been deleted. Use ticket 2's cases instead, not the old ones. All runs go on the fork `jamesbeeson01/Applr`, branch `test-suite-revision`. The shared repository is off limits.

## Experiment

- [ ] Run the suite's own cases on Windows, macOS and Ubuntu with pinned versions (`install_pinned.R`, `versions.csv`; refresh the pins if ticket 2 needs new packages). Compare their fingerprints with the maintainer's machine.
- [ ] A missing input stops the run with an error. It never records an output that could "match".
- [ ] The results table covers every output type that exists, and confirms or refutes hypotheses H1–H7 from the spec, with the cause of each mismatch.
- [ ] **Pause.** Write the two deferred decisions into the spec's *CI* section:
  - how each review status maps to ✓ / ✗ / warning;
  - whether local fingerprints are authoritative on every platform.

  Get the maintainer's approval before building on them.

## Build

- [ ] The ✓/✗ policy per review status, as approved.
- [ ] States that render with a different fingerprint on another platform are uploaded as a downloadable bundle for review.
- [ ] A platform variant of a Human approved output needs only agent approval, with a note on what differs.
- [ ] A release check fails while anything is Unreviewed, Rejected, or Agent approved (other than a platform variant). It also runs the spec's release audit: re-render every state and compare it with the screenshot kept from its approval on the same machine.
- [ ] Expectations run within CRAN limits under R CMD check.
- [ ] Once the results are in the spec, delete the throwaway experiment: `for_devs/experiments/03-cross-platform/` and its `xplat-experiment` workflow.
