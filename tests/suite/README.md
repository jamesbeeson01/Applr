# Judged-output suite (dev-only)

Not shipped in the package (`.Rbuildignore`). Needs `vdiffr`, `digest`,
`processx` and, for screenshots of interactive states, `chromote` with Chrome.
Vocabulary: `GLOSSARY.md`; design: `for_devs/test_suite_spec.md`.

> When you change this file, update the review page's suite guide pages
> (principles and structure) to match. They are the maintainer's plain-language
> version of it.

A case is `tests/testthat/test-case_<name>.R`: ordinary testthat expectations
(shipped, run by CRAN) plus `judged_output()` calls that declare what a
reviewer judges. From the package root:

```sh
Rscript tests/suite/suite.R run                 # run cases, fingerprint outputs
Rscript tests/suite/suite.R list                # Unreviewed outputs
Rscript tests/suite/suite.R diff <id>           # text diff vs last approved
Rscript tests/suite/suite.R approve <id> "note" # agent approval (note required)
Rscript tests/suite/suite.R reject  <id> "note"
Rscript tests/suite/test.R                      # unit tests for this module
Rscript tests/suite/mutate.R                    # mutation check of those tests
```

`review_state.json`, `forms/` and `mutation_report.json` are committed. Views
(PNGs, HTML, screenshots, live widget pages) go to the gitignored
`tests/output/` and are for viewing only.

Human decisions live in their own file, `human_decisions.json`, which only
the review server (Part B, not built yet) writes. An output is Human approved
only while that file approves its current fingerprint. Because no agent
command ever writes the file, a Claude Code hook blocks every agent write to
it by path.

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
or the views are missing. An agent approval keeps a copy of them under
`tests/output/approved/` for comparison.

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
