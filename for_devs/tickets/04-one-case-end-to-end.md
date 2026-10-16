# 04: One case end to end

**What to build:** The first working path through the whole model, with one new case written from scratch: a single-predictor model whose plotted line is checked against the model's predictions (an expectation), plus one judged output (the plot). Running the suite evaluates the expectation, fingerprints the plot, and records it as Unreviewed. An agent can list Unreviewed outputs and approve or reject them with a required note.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] The testthat layout for cases exists, and the expectation ships in the built package and runs under R CMD check
- [ ] The judged output is fingerprinted as defined in 01; its rendered image is saved for viewing only
- [ ] Static-plot fingerprints pass the trust tests from the spec's *Trusting a fingerprint*: the SVG that is hashed is rendered from the same plot object the case returns (completeness); changing one input at a time (a coefficient, a theme element, a label) changes the fingerprint (sensitivity); and two builds in different temp folders and R sessions give the same fingerprint (stability)
- [ ] The review state file records fingerprint, review status, who, when, and notes per judged output
- [ ] Review status rules follow the spec's transition table, unit-tested as a pure function
- [ ] A command lists Unreviewed outputs, shows a text diff against the last approved version, and records agent approve/reject with a required note
- [ ] Changing the plot's appearance resets its status to Unreviewed; re-running unchanged keeps it
- [ ] Breaking the line fails the expectation and leaves review state untouched
