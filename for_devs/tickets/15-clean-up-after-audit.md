# 15: Clean up after the salvage audit

**What to build:** The old suite itself was deleted from this branch before the writing tickets started, and survives only in the `old-suite` tag. Once the audit is done, remove the temporary files that bridged to it, so nothing from it can shape later work.

**Done when:** the inventory and the audit log are gone, nothing in the working tree refers to the old suite, and the new suite and R CMD check pass on the branch.

**Blocked by:** 08, 13, 14

**Status:** ready-for-agent

- [ ] Removed: the temporary behaviour inventory and the salvage audit log
- [ ] The dev docs (including `testing_revisions.md`) and `CLAUDE.md` have no references left to old case IDs or old suite paths, other than the `old-suite` tag
- [ ] A repository search for old case IDs (`gs_`, `as_`, `ap_`, `s2_`, `sb_`, `gt_`, `le_`, `la_`, `cp_`) and for `tests/run.R` finds nothing
- [ ] The maintainer decides whether to keep the `old-suite` tag or delete it
- [ ] The full new suite and R CMD check pass on the branch
