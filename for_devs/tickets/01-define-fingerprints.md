# 01: Define fingerprints for each output type

**What to build:** A section of the test suite spec stating, for every output type, what its fingerprint is taken from, what its states are, and what noise is removed first. Output types: static ggplot, base graphics, condition text, slider widget, plotly 3D, animation. Anyone (agent or human) can then fingerprint any output the same way, and extend the rules to a new output type.

**Blocked by:** None (can start immediately)

**Status:** done

- [x] Each output type has: its states, the serialised form (e.g. fixed-font SVG, plotly JSON, slider payload), and the normalisation rules (rounding, stripped IDs/timestamps)
- [x] Prior art is checked and cited: vdiffr's fixed-font SVG engine for ggplot and base graphics
- [x] States for interactive outputs and animations are defined as data produced by a compute step, not by driving a browser
- [x] Open risks for cross-platform matching are listed as hypotheses for ticket 03 to test
- [x] The spec uses the glossary terms in GLOSSARY.md; any new term is added there
- [x] One general principle decides what any output type fingerprints, so ticket 13's guide can apply it to new types
- [x] Interactive outputs and animations get one fingerprint each, taken from their renderer's inputs (for sliders, the payload every position borrows from), not one per sampled state
- [x] The spec says how a fingerprint is trusted: completeness by construction, sensitivity tests, stability tests and a release audit

**Revision (2026-10-15):** reopened because the first version fingerprinted each slider state from a recipe render. That covered a sample instead of the whole widget, cost one render per state on every run, and missed changes to the payload the page actually draws from.
