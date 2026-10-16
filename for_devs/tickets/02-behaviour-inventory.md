# 02: Write a behaviour inventory from the docs and source

**What to build:** A temporary, principle-based behaviour inventory next to the spec, saying what each exported function must do. It is written from what the package says and does, never from the old suite: the writing tickets (09–12) work from it, and the old suite is only consulted afterwards, by the salvage audit (14).

Sources:
- the roxygen docs (`R/*.R`, `man/`), the vignettes, `README.Rmd` and `GLOSSARY.md`, for what each function is for, and the plots that show it;
- the dev docs (`for_devs/knowledge_base.Rmd`, `decisions.Rmd`, `known_issues.Rmd`, `testing_revisions.md`), for decisions and known edge cases;
- the source in `R/`, for edge cases: every condition raised (`stop()`, `warning()`, `message()`, `cli_abort()` and friends) and every branch on the kind of input (factor or numeric, transformed or not, data given or not).

The old suite, kept only in the `old-suite` tag, is not read. If a dev doc mentions an old case ID, take the principle from the note itself and don't look the case up.

**Done when:** the maintainer has reviewed an inventory that states every exported function's behaviours and edge cases as principles, tagged by test type, written without reference to the old suite.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] For each exported function: what it must do, stated as principles
- [ ] For each function: its edge cases, each with the principle at stake, where it comes from (doc, decision, or source line), and workable options for testing it
- [ ] Shared behaviours across functions (input validation, back-transforms, imputation, facet/group slicing, held values) are pulled out so each is tested once
- [ ] Each behaviour is tagged with its test type (numeric, condition, static appearance, interactive) so the writing tickets can split by type
- [ ] Each function names the doc or vignette plots that show its purpose, as the starting point for its appearance outputs
- [ ] No entry names an old case, quotes an old `# EXPECT:` header, or relies on a reference image
- [ ] The inventory is marked temporary at the top, to be deleted by ticket 15
- [ ] Recommends whether ticket 09 should be split, based on how many numeric behaviours turn up
- [ ] Maintainer reviews the inventory before writing tickets start
