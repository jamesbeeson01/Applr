# 03: Cross-platform fingerprint experiment

**What to build:** A throwaway experiment that answers: do fingerprints match across Windows, macOS and Linux? It renders about 10 existing cases plus prototype slider and animation outputs, fingerprints them as defined in ticket 01, locally and on GitHub, and reports matches per output type. Its result settles the two open decisions in the spec: how GitHub runs treat each review status, and whether local fingerprints are authoritative everywhere.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A GitHub workflow runs only on pushes to the test-suite branch (on the shared repo, not a fork), without changing the workflows on `main`
- [ ] Identical package versions are installed on every machine, and `sessionInfo()` is recorded with each result
- [ ] It covers Windows (the maintainer's machine and GitHub), macOS and Ubuntu
- [ ] It covers every output type: static ggplot, base graphics, condition text, slider states, plotly JSON, animation frames
- [ ] A results table reports match / no match per type and platform, with the cause of any mismatch
- [ ] The spec's deferred decisions are updated from the results, and approved by the maintainer
- [ ] Experiment code is clearly marked throwaway and kept off the final suite
