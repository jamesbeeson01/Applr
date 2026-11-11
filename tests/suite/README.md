# Judged-output suite (dev-only)

Not shipped in the package (`.Rbuildignore`). Needs `vdiffr`, `digest`,
`processx`, `httpuv` and `yaml`, and, for screenshots of interactive states,
`chromote` with Chrome. Vocabulary: `GLOSSARY.md`; design:
`for_devs/test_suite_spec.md`.

> When you change this file, update the review page's suite guide pages
> (principles and structure) to match. They are the maintainer's plain-language
> version of it.

A case is `tests/testthat/test-case_<name>.R`: ordinary testthat expectations
(shipped, run by CRAN) plus `judged_output()` calls that declare what a
reviewer judges. From the package root:

```sh
Rscript tests/suite/suite.R run                 # run cases, fingerprint outputs
Rscript tests/suite/suite.R list                # Unreviewed outputs
Rscript tests/suite/suite.R diff <id>           # text diff vs last human-approved version
Rscript tests/suite/suite.R approve <id> "note" # agent approval (note required)
Rscript tests/suite/suite.R reject  <id> "note"
Rscript tests/suite/review.R [port]             # the review page, for the maintainer
Rscript tests/suite/test.R                      # unit tests for this module
Rscript tests/suite/mutate.R                    # mutation check of those tests
```

`review_state.json`, `human_decisions.json`, `forms/`, `test_report.json` and
`mutation_report.json` are committed. Views (PNGs, HTML, screenshots, live
widget pages) go to the gitignored `tests/output/` and are for viewing only.

## Review status and human decisions

`review_state.json` holds what the runner and agents record: fingerprint,
part hashes, the runner's or agent's status, notes. It never holds Human
approved. Human decisions live in `human_decisions.json`, one entry per
decision (output ID, fingerprint judged, approve or reject, note, date),
written only by the review server.

`review_records()` in `store.R` is the one place status is worked out: the
latest human decision for the current fingerprint wins, otherwise the status
in `review_state.json`. A decision for an older fingerprint has no effect, so
a changed output is Unreviewed again without anyone editing the decisions.
`list`, the agent commands and the review page all read status through it.

A human approval also keeps that version's form (`forms/approved/`) and views
(`tests/output/approved/`). They are what `diff` and the page's comparison are
taken against, so both always show what changed since the maintainer last
signed off. An agent approval keeps nothing.

## The review page

`Rscript tests/suite/review.R` starts a local server (httpuv, on
`127.0.0.1:7654`; pass a port to change it) and opens the page. From an R
session, `source("tests/suite/review.R")` leaves it running in the background
until `stop_review_server()`. The page re-reads the review state on every
load, so a re-run or an agent decision shows on refresh.

- The suite overview (tiles by family, coloured by status) is the default
  view, unless the link names an output. The sidebar groups every output by
  status, with search; "your turn" is the inbox of Agent approved outputs.
  The page follows the system's light or dark setting.
- Each output shows its expected behaviour (from the inventory entries its
  case cites), the agent note, and its view kind: an image with swipe or
  side-by-side comparison against the last human-approved render, a text
  diff, or sampled states plus the live widget.
- Approve, or reject with a note (starter phrases offered). Keys: `j`/`k`
  next/previous in the queue, `a` approve, `r` reject, `Ctrl+Enter` send the
  rejection, `Esc` cancel, `s` swipe/side by side, `o` overview, `[` sidebar.
- Sidebar pages: the overview, the behaviour inventory with coverage, suite
  health (latest `test.R` and `mutate.R` runs, with date and commit), and, at
  the bottom, the guide (principles, structure) in `page/guide.html`.
- Deep links: `?output=<id>`, `?case=<case>`, `?view=overview|inventory|health|principles|structure`.
  `suite.R` prints the link for each output it names.

`server.R` accepts a decision only as JSON from the page's own origin
(`POST /api/decide`, with the fingerprint the page showed), checks the move
with `review_transition()`, and appends it to `human_decisions.json`. It serves
files only from `page/` and the view folder.

> The guide pages (`page/guide.html`) restate this README and the spec in
> plain language. Update them when either changes.

## The human-authority hook

Two entries in `.claude/settings.json` block any agent write to
`human_decisions.json` by path. A permission deny rule,
`Edit(tests/suite/human_decisions.json)`, covers the file-edit tools.
`.claude/hooks/protect_human_decisions.R`, a PreToolUse hook on `Bash` and
`PowerShell`, blocks commands that name the file (even to read it; the Read
tool is fine). Agent commands never touch the file, so nothing legitimate is
blocked. The project `.Rprofile` attaches devtools only in interactive
sessions, so the hook's `Rscript` starts quickly. It's a guardrail against careless agents, not a lock (spec: *Human
authority*). `unit/test-hook.R` shows a blocked edit, a blocked shell write
and an allowed `suite.R approve`.

## Behaviour inventory

`for_devs/behaviour_inventory.yml` (temporary; ticket 2 writes it, ticket 4
deletes it) is read by `inventory.R`:

```yaml
functions:
  geom_slice:
    family: geom_slice        # overview row; defaults to the function name
    purpose: One line on what it's for.
    behaviours:
      - id: geom_slice.line-is-prediction    # stable, unique, lower case
        principle: The rule, in plain language.  # required
        source: "?geom_slice; R/geom_slice.R"
    edge_cases:
      - id: geom_slice.factor-x
        principle: ...
        source: ...
        options: ["Expectation: ...", "Judged output: ..."]
        deferred: Why it isn't covered yet.       # only if it isn't
shared:
  imputation:                 # behaviours that cut across functions
    purpose: ...
    functions: [geom_slice, slice_2d]
    behaviours: [...]
    edge_cases: [...]
```

A case cites what it covers with `covers("<id>", ...)` (string literals,
anywhere in the file); the page reads them without running the case. An ID
used twice, an entry with no principle, or a case citing an unknown ID is
flagged. A case's overview family is that of the first function entry it
cites.

## Output types

Every judged output has an output type, and every type is one registration
in its own file under `types/`. The runner, the review state and the review
page reach a type only through the contract in `types.R`, and never name one
(a unit test checks this).

```r
judged_output("plot", p)                                  # type worked out: a ggplot
judged_output("plot", function() slice_2d(m), type = "base_graphics")
judged_output("wording", function() geom_slice(m), type = "conditions")
judged_output("widget", scatter_3d(m), states = list(top = list(eye = list(x = 0, y = 0, z = 2.5))))
```

`type` can be left out when the object alone says it (a ggplot, a plotly
widget); a function needs it, since it could be drawing code or a call whose
conditions are judged. `states` are the case's declared states, if the type
takes any.

A registration gives:

| Field | What it is |
|---|---|
| `serialise(object, states)` | Returns `list(parts, engine_version, view)`. `parts` is a named list of text; the core runs the common normalisation on each part and fingerprints them. `view` is what views are drawn from, so a view always comes from the build that was hashed. |
| `states(declared)` | The named list of states a reviewer sees, given what the case declared. |
| `render(view, state, file, live)` | Writes one state's view to `file`, as `format` (`"png"` or `"html"`). |
| `view` | How the review page shows it: `"image"` (one state, compared against the last approved render), `"text"` (a diff of the serialised form) or `"states"` (sampled states side by side, plus the live page if there is one). |
| `live(view, file)` | Optional. Writes an interactive page that defines `window.applrSetState(state)`, so screenshots of states are deterministic. |
| `detect(object)` | Optional. Claims an undeclared object. Leave it out when the object is ambiguous. |
| `mutations` | Named functions, each changing one input of `list(object, states)`. The shared tests assert that each one changes the fingerprint. |
| `demo` | The case the shared tests use. |

Registered: `static_plot`, `base_graphics`, `conditions` and `plotly_3d`, with
demo cases `single_predictor_line`, `base_slice_2d`,
`condition_imputed_values` and `scatter_3d_two_predictors`.

Views are rendered only for Unreviewed outputs, when the fingerprint is new
or the views are missing. A human approval keeps a copy of them under
`tests/output/approved/` for comparison.

The review page draws each view kind generically: a state file ending in
`.png` is shown as an image and one ending in `.html` in a frame, so a new
type needs no page changes.

### Adding an output type

1. Write `types/<name>.R` with one `register_output_type()` call.
2. Write its demo case, `tests/testthat/test-case_<demo>.R`.
3. Give it mutations. `unit/test-contract.R` then runs the completeness,
   sensitivity and stability tests on it, with no other edits.

`unit/test-fake-type.R` shows the whole path for a type the suite has never
seen: a travel itinerary with four parts, five states and an HTML view,
defined only in that test file.

## Testing the tests

`mutate.R` applies known breaks to a temporary copy of the suite, one at a
time, and runs the unit tests on each copy. Every break must be caught; a
break that isn't means a test is missing. Add a break whenever a new rule is
added to the core or a type.
