# 02: Salvage the old suite into a behaviour inventory

**What to build:** A dedicated salvage session that mines the old suite and writes a temporary, principle-based behaviour inventory next to the spec. It is the only link between the old suite and the new one: later writing tickets read the inventory, never the old cases.

Sources: every old case's `# EXPECT:` header and test code, the reference-image build scripts, and the maintainer's notes on testing revisions in the dev docs.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] For each exported function: what it must do, stated as principles, not old assertion wording
- [ ] For each function: the edge cases that came up, each with the principle at stake and workable options for testing it
- [ ] Shared behaviours across functions (input validation, back-transforms, imputation, facet/group slicing, held values) are pulled out so each is tested once
- [ ] Each behaviour is tagged with its test type (numeric, condition, static appearance, interactive) so the writing tickets can split by type
- [ ] Salvageable test code (data generators, models, oracle builders, helpers) is listed with why it's worth keeping
- [ ] Known problems with the old suite are recorded (e.g. reference images that were slightly off)
- [ ] The inventory is marked temporary at the top, to be deleted by ticket 14
- [ ] Recommends whether ticket 09 should be split, based on how many numeric behaviours turn up
- [ ] Maintainer reviews the inventory before writing tickets start
