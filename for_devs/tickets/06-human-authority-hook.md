# 06: Human-authority hook

**What to build:** Make "only a person grants Human approved" real. A Claude Code hook stops agents writing the human part of the review state; the review server stays its only writer.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] The hook blocks agent edits that would set or change Human approved, through file-edit and shell tools alike
- [ ] Agent approve/reject through the agent command still works
- [ ] A test demonstrates a blocked attempt and an allowed agent action
- [ ] The hook is committed with the project settings and explained in the guide (ticket 13)
