# Test suite revision: tickets

Design: `../test_suite_spec.md`. Vocabulary: `../../GLOSSARY.md`. Each ticket is one session, and they run in order. Each one pauses only where it says **Pause**.

| # | Ticket | Pauses for the maintainer |
|---|---|---|
| 1 | [Backend and interface](1-backend-and-interface.md) | Approve the backend (contract, fake-type test, mutation report) before the review page is built |
| 2 | [Behaviour inventory and cases](2-inventory-and-cases.md) | Confirm the inventory's gist in chat; then review outputs in the review page |
| 3 | [CI and release check](3-ci-and-release-check.md) | Approve the two CI decisions |
| 4 | [Salvage audit, clean-up and guide](4-salvage-and-finish.md) | Review the salvage additions and discards; decide on the `old-suite` tag |

Already done, before this list: fingerprints defined per output type (spec), and one static case end to end (`tests/suite/`, `single_predictor_line`). The cross-platform experiment is half done; ticket 3 finishes it.

Later, not ticketed: slider and animation cases, once those features exist (each is a new output type registration), and vignette figures as judged outputs.
