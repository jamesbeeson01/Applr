# 08: GitHub integration and release check

**What to build:** GitHub runs on the test-suite branch report each review status as the experiment (03) decided, platform variants flow through agent review, and a release check blocks a CRAN submission until everything is Human approved.

**Blocked by:** 03, 04

**Status:** ready-for-agent

- [ ] The ✓/✗ policy per review status is implemented as recorded in the spec after 03
- [ ] Mismatched states from other platforms are uploaded as a downloadable bundle for review
- [ ] Platform variants of Human approved outputs need only agent approval with a note
- [ ] The release check fails while anything is Unreviewed, Agent approved (other than platform variants) or Rejected
- [ ] Expectations run within CRAN limits (about a minute, two threads or fewer); anything needing a browser is skipped on CRAN
