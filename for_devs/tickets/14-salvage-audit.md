# 14: Salvage audit of the old suite

**What to build:** Once the new suite is written, go through the old suite once to find what it caught that the new one doesn't. This is the only ticket that reads the old suite. The question for each old case is not "is this behaviour new?" but "what kind of situation was this case putting the function in, and does the new suite put it there too?"

The old suite was deleted from this branch and is kept only in the `old-suite` tag (the last `main` commit before the rewrite). Read it from there with `git ls-tree -r old-suite tests` and `git show old-suite:<path>`, or in a throwaway worktree, and don't restore any of it onto the branch. Work and commit on the test suite branch as usual.

Sources in the tag: `tests/cases/`, `tests/expected/`, `tests/reference/` and its build scripts, `tests/_helpers.R`, `tests/_setup.R`, the old testthat files (`test-geom_slice.R`, `test-plots.R`, `test-lm_equation.R`, `test-deprecated.R`), and the real student models in `tests/archive/`.

Look for these kinds of things, and check each against the new suite:

1. **Model shapes.** Interactions (with and without a factor), polynomial terms (`I(x^2)`, `poly()`), transformed predictors (`log(x)`), each transformed response (log, sqrt, inverse, exp, square), factor or character predictors (including a factor as the first predictor), `$` in formulas, models fit without `data =` or from data in a local scope, and data with `NA` rows.
2. **Argument forms.** Every accepted and rejected form of each argument: `back_transform` as `TRUE`/`FALSE`, a function, a name, a number, or a function with extra arguments; `x_axis` as a name, an expression, a missing variable, or a factor; single and multi-value `predict_vars`; explicit and imputed held values; each interval type; `mapping` overrides, including non-model variables; and `...` passthrough.
3. **Plot contexts.** Grouping by colour or linetype, faceting, and both at once; a plot built from different data than the model; base graphics with no plot open, or with an x-axis or y-transform that doesn't match the model.
4. **Numeric boundaries.** Back-transforms evaluated outside their domain, values at or near zero, prediction beyond the data range, and very small datasets.
5. **Text and layout.** Long equations and labels that wrap, subtitles and captions with facets, and legends.
6. **Conditions from dependencies.** Warnings or messages a user sees from ggplot2 or others, such as rows being dropped.
7. **Platform fixes.** Anything changed for Linux or Windows (curly quotes, near-zero rounding, line endings). Confirm the spec's normalisation covers it rather than adding a case.
8. **Real usage.** Model forms in the student analyses that none of the above covers.

Discard by default, and say so in the log:
- anything whose only point is old infrastructure (console/visual types, snapshot quirks, blank-PNG detection);
- details of the reference images, which were an eyeball oracle and are known to be slightly off in places (gs_38, gs_39);
- old message and `# EXPECT:` wording.

**Done when:** every old case and old testthat test is accounted for in the audit log, each gap is a new case in the new suite, and the maintainer has reviewed the additions and the discards.

**Blocked by:** 09, 10, 11, 12

**Status:** ready-for-agent

- [ ] A temporary audit log in `for_devs/` gives every old case one line: covered by (new case), added as (new case), or discarded (reason); it is marked temporary, to be deleted by ticket 15
- [ ] Each gap is first written into the inventory as a principle, marked as coming from the old suite, then written as a new case from that principle by the rules of its test type's ticket
- [ ] No old code, `# EXPECT:` wording or reference image is copied into the new suite; an old data generator or model is adopted only when the new suite has nothing equivalent, and is rewritten into the new suite's helpers
- [ ] New cases pass, and their judged outputs are Agent approved and waiting in the maintainer's queue
- [ ] The maintainer reviews the additions and the discards
