# 14: Retire the old suite

**What to build:** Remove everything the new suite replaces once it's complete.

**Blocked by:** 08, 09, 10, 11, 12, 13

**Status:** ready-for-agent

- [ ] The old runner, console/visual case types, old cases, expected snapshots, the report and the reference images are removed
- [ ] The temporary behaviour inventory is deleted
- [ ] The testthat shim around the old runner is removed, and the build-ignore list is updated
- [ ] The full new suite and R CMD check pass on the branch
