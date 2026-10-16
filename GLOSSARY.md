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
Any output whose correctness needs a reviewer's judgment: plot appearance, message wording, an interactive output or an animation. Every judged output has one fingerprint and one review status, and is judged as a whole.
_Avoid_: Visual case, console case, snapshot

**State**:
One sampled view of a judged output: the single image of a static plot, one slider position, one camera angle, or one animation frame. States decide what a reviewer sees; they are never fingerprinted on their own.
_Avoid_: Frame (except for animations), screenshot

**Fingerprint**:
A short hash of a judged output's serialised form, taken from the inputs of its renderer, so one fingerprint covers every state. Identical text gives an identical fingerprint. A fingerprint never decides correctness; it only tells whether an output is the same one that was last reviewed.
_Avoid_: Hash (in prose), snapshot, checksum

**Serialised form**:
The text a judged output becomes once noise is removed, and the input to its fingerprint: fixed-font SVG for plots, message text for conditions, and named parts such as a payload, a background and a shell for interactive outputs.
_Avoid_: Snapshot, dump

**Compute step**:
The R code that produces a judged output's serialised form, as data or as a ggplot, without a browser. For a static plot it is just building the plot. Interactive outputs and animations must expose theirs separately from the code that draws them.
_Avoid_: Render step

**Shell**:
The part of an interactive output's or animation's serialised form that holds configuration and code rather than data: slider ranges, widget dependencies, hashes of the JS and CSS Applr ships, or frame timing.
_Avoid_: Wrapper, chrome

**Payload**:
The data an interactive output's page computes every state from, such as a slider's per-line designs, slider tables and coefficients. It is one part of the serialised form, and is the same object the widget embeds.
_Avoid_: Bundle, state data

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
