# 4: Salvage audit, clean-up and guide

**What to build:** With the new suite written, go through the old suite once to find what it caught that the new one doesn't, and add what's missing. Then remove everything temporary, and turn the tests README into the guide for extending the suite.

**Done when:**
- every old case and old testthat test is accounted for in the audit log;
- each gap is a new case, and the maintainer has reviewed the additions and the discards;
- nothing temporary or old-suite-related is left in the working tree;
- someone new can add a case or an output type by following the tests README alone;
- the full suite and R CMD check pass on the branch.

**Blocked by:** 2 (the audit), 3 (the clean-up)

**Status:** ready-for-agent

## Salvage audit

This is the only ticket that reads the old suite. The question for each old case is not "is this behaviour new?" but "what kind of situation was this case putting the function in, and does the new suite put it there too?"

The old suite is kept only in the `old-suite` tag (the last `main` commit before the rewrite). Read it with `git ls-tree -r old-suite tests` and `git show old-suite:<path>`, or in a throwaway worktree. Don't restore any of it onto the branch.

Sources in the tag:
- `tests/cases/`, `tests/expected/`, `tests/reference/` and its build scripts;
- `tests/_helpers.R` and `tests/_setup.R`;
- the old testthat files: `test-geom_slice.R`, `test-plots.R`, `test-lm_equation.R`, `test-deprecated.R`;
- the real student models in `tests/archive/`.

Look for these kinds of situation, and check each against the new suite:
1. **Model shapes.**
   - interactions, with and without a factor;
   - polynomial terms (`I(x^2)`, `poly()`) and transformed predictors (`log(x)`);
   - each transformed response: log, sqrt, inverse, exp, square;
   - factor or character predictors, including a factor as the first predictor;
   - `$` in formulas;
   - models fit without `data =`, or from data in a local scope;
   - data with `NA` rows.
2. **Argument forms.**
   - every accepted and rejected form of `back_transform`;
   - `x_axis` as a name, an expression, a missing variable, or a factor;
   - single and multi-value `predict_vars`;
   - explicit and imputed held values;
   - each interval type;
   - `mapping` overrides, including variables that aren't in the model;
   - `...` passthrough.
3. **Plot contexts.**
   - grouping by colour or linetype, faceting, and both at once;
   - a plot built from different data than the model;
   - base graphics with no plot open, or with an x-axis or y-transform that doesn't match the model.
4. **Numeric boundaries.** Back-transforms evaluated outside their domain, values at or near zero, prediction beyond the data range, very small datasets.
5. **Text and layout.** Long equations and labels that wrap, subtitles and captions with facets, legends.
6. **Conditions from dependencies.** Warnings or messages a user sees from ggplot2 or other packages, such as rows being dropped.
7. **Platform fixes.** Anything changed for Linux or Windows (curly quotes, near-zero rounding, line endings). Confirm the spec's normalisation covers it rather than adding a case.
8. **Real usage.** Model forms in the student analyses that none of the above covers.

Discard by default, and say so in the log:
- anything whose only point is old infrastructure (console/visual types, snapshot quirks, blank-PNG detection);
- details of the reference images, which were an eyeball oracle and are known to be slightly off in places;
- old message and `# EXPECT:` wording.

- [ ] A temporary audit log in `for_devs/` gives every old case one line: covered by (new case), added as (new case), or discarded (reason).
- [ ] Each gap is first added to the inventory as a principle, marked as coming from the old suite. It is then written as a new case by ticket 2's rules for its test type.
- [ ] No old code, `# EXPECT:` wording or reference image is copied. An old data generator or model is adopted only when the new suite has nothing equivalent, and is then rewritten into the new suite's helpers.
- [ ] New cases pass, and their judged outputs are Agent approved and waiting in the queue.
- [ ] **Pause.** The maintainer reviews the additions and the discards.

## Clean-up

- [ ] Remove the temporary behaviour inventory and the audit log. If the review page's inventory view still needs a source, keep only what it reads, and drop the "temporary" banner.
- [ ] The dev docs (including `testing_revisions.md`) and `CLAUDE.md` have no references left to old case IDs or old suite paths, other than the `old-suite` tag. A repository search for `gs_`, `as_`, `ap_`, `s2_`, `sb_`, `gt_`, `le_`, `la_`, `cp_` and `tests/run.R` finds nothing.
  The review page prototype in `for_devs/prototypes/` mentions old case IDs, so it is exempt from this search.
- [ ] Ask the maintainer whether to keep or delete the `old-suite` tag, and the prototype.

## Guide

- [ ] `tests/suite/README.md` becomes the guide for extending the suite. It covers:
  - writing a case: expectations, judged outputs and the inventory IDs it cites;
  - choosing the highest seam;
  - adding an output type through the contract: its renderer's inputs, serialised parts, states, view kind and trust-test mutations, with an animation worked through on paper as the example;
  - running the suite, agent review, the review page, the mutation check and the human-authority hook.
- [ ] It uses the glossary vocabulary consistently, and notes that it may become a skill later.
- [ ] `CLAUDE.md`'s testing section just points to it.
- [ ] The full suite and R CMD check pass on the branch.
