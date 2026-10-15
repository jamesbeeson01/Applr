# 01: Define fingerprints for each output type

**What to build:** A section of the test suite spec stating, for every output type, exactly what a state is, what text form gets fingerprinted, and what noise is removed first. Output types: static ggplot, base graphics, condition text, slider widget, plotly 3D, animation. Anyone (agent or human) can then fingerprint any output the same way.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Each output type has: its states, the serialised form (e.g. fixed-font SVG, plotly JSON, state data), and the normalisation rules (rounding, stripped IDs/timestamps)
- [ ] Prior art is checked and cited: vdiffr's fixed-font SVG engine for ggplot and base graphics
- [ ] States for interactive outputs and animations are defined as data produced by a compute step, not by driving a browser
- [ ] Open risks for cross-platform matching are listed as hypotheses for ticket 03 to test
- [ ] The spec uses the glossary terms in CONTEXT.md; any new term is added there
