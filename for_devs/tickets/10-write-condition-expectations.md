# 10: Write condition expectations

**What to build:** From the behaviour inventory, write from scratch the condition cases: errors, warnings and messages checked by class and key fields, plus "a plot is still built" wherever the behaviour calls for it. Message wording becomes a judged output that goes through agent review.

**Blocked by:** 02, 04

**Status:** ready-for-agent

- [ ] Every condition behaviour in the inventory is covered, or explicitly deferred with a reason
- [ ] Shared validation (e.g. non-lm models, `$` in formulas, character variables) is tested once
- [ ] Each message's wording is a judged output with a fingerprint
- [ ] Wording follows the package's two-part condition format in the dev decisions doc
- [ ] Agent review notes exist for every wording output
