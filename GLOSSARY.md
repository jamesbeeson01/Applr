# Applr

An R package for visualizing and explaining linear models. This glossary covers the package's own vocabulary, starting with its test suite.

## Language

### Test suite

**Case**:
One scenario the suite exercises, kept in its own file. A case holds any mix of expectations and judged outputs.
_Avoid_: Test (ambiguous), test file

**Expectation**:
A deterministic pass/fail statement about a case, such as "the line equals the model's prediction on this grid" or "this warning class is raised". Expectations never get a review status. They are the only part of the suite that runs during R CMD check on CRAN.
_Avoid_: Check (collides with R CMD check), tier 0, assertion

**Judged output**:
Any output whose correctness needs a reviewer's judgment: plot appearance, message wording, or the states of an interactive output or animation. Every judged output has a fingerprint and a review status.
_Avoid_: Visual case, console case, snapshot

**State**:
One sampled moment of a judged output: the single image of a static plot, one slider position, one camera angle, or one animation frame. Each state is fingerprinted.
_Avoid_: Frame (except for animations), screenshot

**Fingerprint**:
A short hash of one output's exact rendered bytes after noise is removed. Identical bytes give an identical fingerprint. A fingerprint never decides correctness; it only tells whether an output is the same one that was last reviewed.
_Avoid_: Hash (in prose), snapshot, checksum

**Review status**:
How far a judged output has been approved: Unreviewed, Agent approved, Human approved, or Rejected. It belongs to one fingerprint; a new fingerprint resets it to Unreviewed.
_Avoid_: Tier, level, approval level

**Agent approved**:
A review status meaning a coding agent has judged the output acceptable and it now waits for a human. It is never a final state, except for a platform variant.

**Human approved**:
The only final review status. Only a person can grant it.

**Rejected**:
A review status meaning a reviewer (agent or human) sent the output back. It carries a rejection note and holds until the code changes the fingerprint.

**Platform variant**:
A state of a Human approved output that renders with a different fingerprint on another operating system. Agent approval alone is enough for it, because a human has already judged the design.

**Rejection note**:
The reviewer's explanation attached to a rejection, written for the agent who will fix the code.
