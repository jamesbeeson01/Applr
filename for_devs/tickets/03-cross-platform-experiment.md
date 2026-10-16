# 03: Cross-platform fingerprint experiment

**What to build:** A throwaway experiment that answers: do fingerprints match across Windows, macOS and Linux? It renders about 10 existing cases plus prototype slider and animation outputs, fingerprints them as defined in ticket 01, locally and on GitHub, and reports matches per output type. Its result settles the two open decisions in the spec: how GitHub runs treat each review status, and whether local fingerprints are authoritative everywhere.

**Blocked by:** 01

**Status:** in-progress (handoff: `for_devs/experiments/03-cross-platform/HANDOFF.md`)

- [x] A GitHub workflow runs only on pushes to the test-suite branch (on the maintainer's fork `jamesbeeson01/Applr`: the shared repo is off limits), without changing the workflows on `main`
- [x] Identical package versions are installed on every machine, and `sessionInfo()` is recorded with each result
- [x] It covers Windows (the maintainer's machine and GitHub), macOS and Ubuntu
- [ ] It covers every output type: static ggplot, base graphics, condition text, slider payloads and backgrounds, plotly JSON, animation frame data
- [ ] A results table reports match / no match per type and platform, with the cause of any mismatch
- [ ] The spec's deferred decisions are updated from the results, and approved by the maintainer
- [x] Experiment code is clearly marked throwaway and kept off the final suite
