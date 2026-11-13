# Handoff: the mutation check on GitHub Actions

Branch `claude/mutate-gha-07b5d6` on the fork (`jamesbeeson01/Applr`). Paused
at the maintainer's request on 2026-11-13. Not merged anywhere.

## What's built

- **`mutate.R --shard i/n`** runs every n-th break from the i-th (round robin),
  plus the unbroken copy, and writes a partial report to
  `tests/suite/mutation_shards/shard-<i>of<n>.json` (gitignored). The partial
  carries `shard`, `of`, `total` and each break's `index`. Without `--shard`
  the run is unchanged. `--full` still works.
- **`mutate.R --merge <dir>`** reads every partial in `<dir>` and checks that
  they agree on `code`, `full`, `tests`, `commit`, `total` and `of`, that shards
  1..n are each there once, and that they cover every break once. It then
  writes `tests/suite/mutation_report.json` in today's format (breaks in list
  order, `index` dropped) and fails if any break was missed or crashed.
  Tested locally with fake partials: good merge, a `code` mismatch, a miss,
  and a missing shard.
- **`.github/workflows/mutation-check.yaml`** is `workflow_dispatch` only, with
  inputs `shards` (default 8) and `full` (default false), guarded to the fork.
  A `plan` job turns `shards` into a matrix; each `shard` job (ubuntu-latest)
  runs setup-r 4.5.3, then restores the R library from `actions/cache` (keyed
  on `pins/versions.csv`). On a miss it installs the pins plus `chromote`,
  `httpuv`, `png` and `yaml`, all used by the suite but unpinned. It then runs
  `mutate.R 4 --shard i/n` and uploads the partial. `merge` downloads the
  partials, deletes the committed report (so a failed merge uploads nothing
  stale), merges, and uploads `mutation-report`.
- README *Testing the tests* and `page/guide.html` describe it.

### Fixes made along the way

- **The break "A platform variant still counts after its original
  changed" crashed every time.** Its `to` replaced the whole `if (...` line
  of `check.R` with `TRUE &&`, leaving the file unparseable. Fixed, and it's
  now caught by `test-check.R: a variant counts only for its platform…`. The
  committed `mutation_report.json` predates the ticket-3 breaks, so this was
  never seen.
- **`suite_code_hash()` differed between Windows and Linux.** It wrote its
  temp file in text mode (CRLF on Windows). A report made in CI would always
  look out of date on the maintainer's machine. It now writes in binary, so
  the hash is the same everywhere. This changes the Windows hash once.
- **Workflow dispatch needs the file on the default branch.** The fork's
  `main` lacks it. One commit added a `push` trigger for this branch to
  register the workflow, and the next commit removed it. After merging,
  dispatch works from any branch.
- `.Rprofile` is removed under `git update-index --skip-worktree`, so the
  report's `commit` isn't marked "+ uncommitted changes".

## What works

[Run 43446436194](https://github.com/jamesbeeson01/Applr/actions/runs/43446436194)
(cached, commit 799c3bc) passed: **43 of 43 breaks caught**, none crashed,
unbroken suite 78 tests. That was before the hash fix, so its `code` is the
Linux hash of that commit. The local runs `--shard 2/44` and `--shard 40/43`
also passed.

## The problem: Chrome on cold runners

Every failure is the same. The **unbroken copy** of some shards fails
`test-contract.R: plotly_3d: completeness` with "Chrome debugging port not
open after 60 seconds" (even after `screenshot_session()`'s retry), so that
shard can't judge its breaks and the merge reports missing shards.

| Run | Change being tried | Result |
|---|---|---|
| [43444675958](https://github.com/jamesbeeson01/Applr/actions/runs/43444675958) | first run, cold, 4 copies per runner | shards 2 and 7 failed on Chrome; shard 8 failed on the crashing break |
| [43446436194](https://github.com/jamesbeeson01/Applr/actions/runs/43446436194) | break fixed, 3 copies per runner, **cache warm** | **all 8 passed**, 5m45s wall |
| [43447674833](https://github.com/jamesbeeson01/Applr/actions/runs/43447674833) | hash fix, 3 copies, cold | 5 of 8 failed on Chrome |
| [43449802530](https://github.com/jamesbeeson01/Applr/actions/runs/43449802530) | 4 copies; start Chrome once, alone, before the check | that start failed outright on shards 1 and 2 (chromote's 10s limit); 3 more failed in the check |
| [43451753681](https://github.com/jamesbeeson01/Applr/actions/runs/43451753681) | same, printing Chrome's own stderr on failure | shards 2 and 5 failed. Chrome took ~15s to print "DevTools listening", spamming D-Bus "Could not parse server address" errors |
| [43453534946](https://github.com/jamesbeeson01/Applr/actions/runs/43453534946) | started a D-Bus session (`dbus-daemon --session`) for the job | warm-up start took 2–12s and passed everywhere, but shards 2 and 3 still failed in the check |
| [43455244477](https://github.com/jamesbeeson01/Applr/actions/runs/43455244477) | drive `chrome-headless-shell` (via `npx @puppeteer/browsers`) with `CHROMOTE_CHROME` | cancelled during setup at the pause; **untested** |

All runners were `ubuntu-26.04`, from two image builds: 20261028 (Chrome
156) and 20261103 (Chrome 157). At first 157 looked like the culprit (alone
it started slowly, 6–15s, against 2–3s for 156). But the passing cached run
was all 157, and cold runs failed on 156 too. **The only clean split so far is
cold vs cached**: the one cached run went 8/8, while the four cold runs lost
2, 5, 5 and 2 shards. Fewer copies (3 instead of 4) didn't help.

### Best guess

Something the cold install does to the runner slows Chrome's start-up badly
enough that four copies starting Chrome together blow the 60s limit. pak
installs system requirements with apt on a cold run (around 9 packages, with
fonts and D-Bus-related libraries among the likely candidates), and the
cached run skips that step. Chrome then rebuilds caches or retries services
at start-up. The D-Bus session helped the single warm-up start, but not the
copies.

### What I'd try next, in order

1. **Rerun the failed shards** of a cold run (`gh run rerun <id> --failed`).
   The passing shards will have saved the cache, so the reruns hit it. This
   is cheap, and it tests the cold/cached theory directly.
2. **The headless shell** (already committed, untested): it skips the
   desktop Chrome's D-Bus/UPower start-up entirely.
3. On a cold run, finish the apt work before the check (e.g. run `fc-cache
   -f`, or start Chrome once *with* the copies' concurrency), and compare.
4. As a workaround, raise chromote's launch timeout (`chromote.timeout`) for
   the copies on CI only. `views.R` already sets it from `screenshot_timeout`
   for sessions.

## Timings

- Wall time, cached run that passed: **5m45s** (dispatch to merge done).
- Wall time, cold runs (all failed, so a lower bound on a passing cold run):
  8m30s–9m50s.
- Setup per shard runner. **Cold:** setup-r 27–73s, plus 125–225s installing
  packages (mostly about 3 min). **Cached:** setup-r 30–58s, plus 1–3s
  restoring the 73 MiB cache.
- Mutation check per shard (8 shards, 4 or 3 copies at a time): 150–250s.
  This includes the unbroken copy, which runs in full every time.
- Merge job: about 40s, nearly all of it setup-r.
- Locally on Windows, one shard of one break plus the unbroken copy: 3m12s.

A GitHub Actions cache saved on a branch is visible only to that branch.
Every branch can also read caches saved on the default branch. So until a run
on the fork's `main` saves one, the first run on each branch is cold.
