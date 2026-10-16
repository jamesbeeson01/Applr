# Judged-output suite (dev-only)

Not shipped in the package (`.Rbuildignore`). Needs `vdiffr` and `digest`.
Vocabulary: `GLOSSARY.md`; design: `for_devs/test_suite_spec.md`.

A case is `tests/testthat/test-case_<name>.R`: ordinary testthat expectations
(shipped, run by CRAN) plus `judged_output("<name>", plot)` calls that declare
what a reviewer judges. From the package root:

```sh
Rscript tests/suite/suite.R run                 # run cases, fingerprint outputs
Rscript tests/suite/suite.R list                # Unreviewed outputs
Rscript tests/suite/suite.R diff <id>           # text diff vs last approved
Rscript tests/suite/suite.R approve <id> "note" # agent approval (note required)
Rscript tests/suite/suite.R reject  <id> "note"
Rscript tests/suite/test.R                      # unit tests for this module
```

`review_state.json` and `forms/` are committed; rendered PNGs go to the
gitignored `tests/output/` and are for viewing only. Only the review server
(future) writes Human approved.
