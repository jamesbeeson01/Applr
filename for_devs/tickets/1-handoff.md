# Handoff: ticket 1, done

**Status (2026-11-10):** Ticket 1 is done. Part A was approved; Part B (the review page) is built, and the maintainer accepted its judgment calls (below). The maintainer applied the hook settings to `.claude/settings.json` themselves, because auto mode won't let an agent edit its own project settings. Ticket 2 is next.

After the Part B review, the maintainer asked for three page changes, now made: the page follows the system's light or dark setting, the suite overview is the default view (the spec is updated), and the guide links sit at the bottom of the sidebar.

Read first: `1-backend-and-interface.md` (the ticket), `tests/suite/README.md` (it now covers status, the page, the hook and the inventory format).

## What was built

| File | What it is |
|---|---|
| `tests/suite/store.R` | `review_records()`: the one place status is derived from `review_state.json` and `human_decisions.json`. `list_unreviewed()`, `agent_decide()` and `review_page_data()` use it. `keep_approved()` keeps a version's form and views. |
| `tests/suite/server.R` | `human_decide()` (the only writer of the decisions file), `review_app()` (httpuv app: page, `/api/data`, `/api/form`, `/api/decide`, `/views/`), `start_review_server()`, `review_url()` |
| `tests/suite/review.R` | The one command: `Rscript tests/suite/review.R [port]`, or `source()` it from R |
| `tests/suite/inventory.R` | `read_inventory()`, `case_covers()` (reads `covers()` from case files without running them), `case_index()` |
| `tests/suite/stamp.R` | `now_stamp()` and `git_commit()`, so `test.R` and `mutate.R` record the date and commit |
| `tests/suite/page/` | `index.html`, `app.js`, `style.css`, and `guide.html` (the principles and structure pages, with a diagram) |
| `for_devs/behaviour_inventory.yml` | The format, plus seed entries for the four demo cases only. Ticket 2 writes the rest. |
| `.claude/hooks/protect_human_decisions.R` | The human-authority hook |
| `tests/testthat/helper-judged.R` | Adds `covers()`, a no-op the page reads from the file |
| `tests/suite/unit/` | New `test-decisions.R`, `test-server.R`, `test-inventory.R`, `test-hook.R`; the fake-type test now goes through the server, through to a human approval |
| `tests/suite/mutate.R` | 13 new breaks (34 in all), for the decisions file, the server's rules and the inventory |

## Judgment calls (accepted by the maintainer)

- **The comparison baseline moved from agent approval to human approval.** In Part A, an agent approval copied the form and views to `approved/`. That made the page compare a new render with itself, since by the time an output reaches the human, the agent has just overwritten the baseline. Now only a human approval (through the server) keeps them, so `suite.R diff` and the page both show what changed since the maintainer last signed off. Before any human approval, there's nothing to compare against.
- **The page's unit is the judged output, not the case.** The queue, deep links (`?output=<id>`) and overview tiles are per output; `?case=<name>` opens a case's first output. Expected behaviour and family come from the case's `covers()`.
- **The inventory is YAML**, read with the `yaml` package (dev-only, like `httpuv`). Cases cite IDs with `covers()`, read statically, so a case with no judged outputs still shows coverage.
- **The server refuses decisions that aren't JSON from its own origin** (and a foreign Host), so another web page can't post one. The page sends the fingerprint it showed, and a decision on a changed output is refused.
- **The hook blocks shell commands that name the file even to read it**, as the ticket says; the Read tool is unaffected.
- **`test_report.json` and `human_decisions.json` are committed**, like `mutation_report.json`.

## Results

- `Rscript tests/suite/test.R`: all pass, including the hook tests. `test_report.json` records the run.
- `Rscript tests/suite/mutate.R`: **34 of 34 breaks caught**; the unbroken suite passes all 60 tests. Took about 30 minutes with 4 workers.
- Browser check on a temp copy, with all four outputs agent approved: rejecting with a starter phrase and Ctrl+Enter, and approving with `a`, both went through the server and advanced the queue. The states view showed the three plotly cameras plus the live widget. The overview, inventory, structure and health pages rendered. `/views/../review_state.json` and its `%2e%2e` form return 404.
- `/api/data` takes about 2 seconds on this machine, mostly the two `git` calls for the commit line. Fine for now.

## Not done

- No real human decisions yet: `human_decisions.json` doesn't exist until the maintainer makes one on the page.
- Platform variants aren't wired into the agent commands (`agent_approve_variant` exists only in `review_transition()`); ticket 3 decides whether it's needed.
- Still open from Part A: the `factor(cyl)` imputation bug on `main` (now a deferred inventory entry).

## Gotchas

- Never pass multi-line R through `Rscript -e` on Windows, and don't write R regexes through bash heredocs. Use the file-edit tool.
- Once the hook is on, agent shell commands can't name the decisions file at all, so use the Grep and Read tools for it.
- `curl` collapses `..` in URLs unless given `--path-as-is`.
