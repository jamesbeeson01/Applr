# 09: Write numeric expectations

**What to build:** From the behaviour inventory, write from scratch the numeric expectations for every function: plotted lines, bands, intervals and held values checked against the model's predictions on independently built grids, read at the highest seam (built layer data, prepared slice data, built plotly traces). Shared behaviours are tested once.

**Blocked by:** 02, 04

**Status:** ready-for-agent

- [ ] Every numeric behaviour and edge case in the inventory is covered, or explicitly deferred with a reason
- [ ] Expectations never read old cases; the inventory is the only source
- [ ] Each shared behaviour has one home, not one copy per function
- [ ] The prediction function is trusted; tests build the expected grid themselves
- [ ] All run under R CMD check within the time budget
- [ ] If the inventory (02) recommended a split, this ticket is split before starting
