# 05: Review page

**What to build:** A local review page, started from R, where the maintainer works through the queue and grants Human approved or Rejected with a note. Layout follows the accepted v2 prototype.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] One command starts a small local server (httpuv) and opens the page
- [ ] The inbox is the default; the collapsible sidebar groups cases by review status, with search
- [ ] The suite overview (tiles by function family, coloured by status) opens from the sidebar
- [ ] The URL deep-links to a single case or to the overview, and the agent command prints these links
- [ ] Each case shows its expected behaviour, the agent note, any console diff, and a swipe or side-by-side comparison against the last approved render
- [ ] Approve and reject write to the review state through the server only; reject requires a note and offers quick starter phrases
- [ ] Keyboard: j/k, a, r, s, o, [, Ctrl+Enter, Esc; queue progress is shown
- [ ] Static outputs reach the human only after Agent approved
