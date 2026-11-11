# 1: Backend and interface

**What to build:** Make the suite work for every output type through one contract, prove it can take output types nobody has designed yet, show the maintainer evidence that its tests catch real bugs, then build the review page on top. Cases (ticket 2) come after this, so the maintainer reads the inventory and every case in the review page rather than in chat.

**Done when:** static plots, base graphics, condition text and `scatter_3d` all run through one output-type contract; a fake output type defined only in a test file goes from run to review page without edits to the core; the mutation report catches every planned break; and the maintainer can start the review page from R, read the inventory there, and approve or reject through the server only.

**Blocked by:** None

**Status:** done

## Starting point

`tests/suite/` already has a working, tested core. Keep it and refactor it; don't start over.
- Keep as they are: `review_transition()` (`status.R`), the common normalisation, `assemble_form()` and `fingerprint_output()` (`fingerprint.R`), the review state layout and the agent commands (`store.R`, `suite.R`). Part B changes one thing: human decisions move to their own file.
- Replace: everything that assumes a static ggplot. Today `run_suite()` calls `fingerprint_static_plot()` on every output, `save_png()` calls `print()`, and `judged_output(name, plot)` takes no type. These become the static plot's registration under the contract.
- The case `single_predictor_line` stays as the static plot's demo case. Its trust tests move onto the shared contract tests.

## Part A: backend. Pause for the maintainer at the end.

- [x] **One output-type contract** (spec: *Output types and states*, *One contract per output type*). One registration per type gives:
  - how to serialise an object into named parts;
  - its states;
  - how to render a state for viewing (PNG or HTML);
  - the view kind the review page draws.

  Every type lives in its own file, and the runner, store and review page never name a specific type.
- [x] `judged_output()` takes the type and the states, or works the type out in one place. It stays a no-op under R CMD check.
- [x] Types built against the contract, each with one demo case:
  - static ggplot;
  - base graphics (drawing code as a function);
  - condition text: every condition the call raises, in order, as the spec's form;
  - plotly 3D, from `scatter_3d`, with camera presets as states.
- [x] Canonical JSON gets a rule for numbers plotly stores as strings, such as colorscale stops (from the cross-platform experiment: they differed in the last bit on Ubuntu). Choose the narrowest rule that will still cover future types, and record it in the spec.
- [x] Completeness, sensitivity and stability tests are written once against the contract. Each type supplies its own "change one input" mutations, so a new type gets the tests by filling in a list.
- [x] **Fake-type test.** A deliberately odd output type is defined only inside a unit test file. For example: four parts, five states, an HTML view, nothing like a plot. It goes through run → fingerprint → states → agent approve → the review page's data with no edits to the core files. This is the proof that future content fits without special cases.
- [x] The transition tests are laid out as a table, one row per row of the spec's transition table, so the two can be compared side by side.
- [x] **Mutation check.** A dev script applies known breaks one at a time to a temporary copy of the suite, runs the unit tests, and reports which breaks were caught. Breaks to include:
  - a changed fingerprint keeps its status;
  - a part is dropped from the serialised form;
  - negative-zero normalisation is skipped;
  - an agent's approval with no note is accepted;
  - an agent writes Human approved;
  - an output's view is rendered from a different object than the one hashed.

  Add any others you find. Every break must be caught. A break that isn't caught means a new test is needed.
- [x] Screenshots of states (headless Chrome via chromote, dev-only) are taken only for Unreviewed outputs. The widget gets a hook that sets a given state, so captures are deterministic.
- [x] **Pause.** Show the maintainer the contract (a short section in `tests/suite/README.md`), the fake-type test and the mutation report, then wait for approval before Part B.

## Part B: interface

The accepted layout is `for_devs/prototypes/review_page_v2.html`.

- [x] One command starts a small local server (httpuv) and opens the page.
- [x] The inbox is the default view. The collapsible sidebar groups cases by review status, with search. The suite overview (tiles by function family, coloured by status) opens from the sidebar.
- [x] The URL deep-links to a single case or to the overview, and the agent command prints these links.
- [x] Each case shows its expected behaviour, the agent note, and its view kind:
  - an image, with swipe or side-by-side comparison against the last approved render;
  - a text diff (condition wording);
  - sampled states side by side, plus the live widget.
- [x] **Inventory view.** Ticket 2 writes the behaviour inventory. Define its file format here, with a stable ID per behaviour, so the page can:
  - show the inventory;
  - show which cases cover each behaviour, and which behaviours are deferred, with their reasons;
  - show a case's expected behaviour taken from the inventory entries it cites.
- [x] **Suite health view.** Shows the latest mutation report and the unit-test results, so the maintainer can check the backend's tests without reading them.
- [x] **Suite guide pages** (one or two, from the sidebar). Written for the maintainer: simple and clear, but complete enough to understand the whole suite without reading it.
  - **Principles:** the two halves of a case, what a fingerprint does and doesn't decide, the review statuses and who can set each, how the suite's own tests are tested, and what CI and CRAN each run.
  - **Structure:** a diagram of the pieces (cases, output types, runner, review state, review server, review page, CI) and how an output flows from run to Human approved.
  - **Latest status:** the most recent unit-test run and mutation check, each with the date and the commit it ran on. `test.R` and `mutate.R` record both in their JSON output.

  The pages restate `tests/suite/README.md` and the spec in plain language, so they go stale when those change. Both files carry a note saying so.
- [x] **Separate human decisions** (decided at the Part A review; spec: *Review state storage*, *Human authority*). The server writes the human's approvals and rejections to `tests/suite/human_decisions.json`, keyed by output ID and fingerprint. `review_state.json` stops holding human statuses. Review status is derived from both files in one place in `store.R`, and the agent commands, `list` and `review_page_data()` all use it. Add mutation breaks: "a human decision for an old fingerprint still counts", and "an agent command writes the decisions file".
- [x] Approve and reject write to `human_decisions.json` through the server only, after checking the move with `review_transition()`. Reject requires a note and offers quick starter phrases. Outputs reach the human only after Agent approved.
- [x] Keyboard: j/k, a, r, s, o, [, Ctrl+Enter, Esc. Queue progress is shown.
- [x] **Human-authority hook.** A Claude Code hook, committed in the project settings, blocks any agent write to `human_decisions.json` by path: file-edit and write tools whose target is that file, and shell commands that name it. Agent commands never touch it, so nothing legitimate is blocked. A test shows a blocked edit, a blocked shell write, and an allowed `suite.R approve`. Replace the stale old-suite entries in `.claude/settings.json` while there.
- [x] `tests/suite/README.md` covers running the suite, the review page, the hook, and how to add an output type. Ticket 4 polishes it into the full guide.

## Out of scope

- The behaviour inventory and real cases (ticket 2); only the demo cases above.
- The slider and animation features themselves. Once they exist, they are added by registering a type, which the fake-type test shows will work.
- CI policy (ticket 3).
