# 13: Guide for extending the suite

**What to build:** A rewritten tests README that tells future agents and contributors how to add a feature or a new output type to the suite. CLAUDE.md's old test iteration loop is replaced by a short pointer to it.

**Blocked by:** 05, 07

**Status:** ready-for-agent

- [ ] Covers: writing a case (expectations plus judged outputs), choosing the highest seam, applying the fingerprint principle to a new output type (its renderer's inputs, serialised parts, states and trust tests, including animation, which doesn't exist yet), running, agent review, the review page, and the human-authority hook
- [ ] Uses the glossary vocabulary consistently
- [ ] CLAUDE.md's testing section is reduced to a pointer, and stale instructions are removed
- [ ] Notes that it may become a skill later
