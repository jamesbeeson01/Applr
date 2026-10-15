# 07: Interactive states (infrastructure)

**What to build:** Support for judged outputs with several states. A case declares an interactive output's states (slider positions, camera presets). Each state is fingerprinted from its data, and deterministic screenshots are captured only for Unreviewed states, so agents can take a first pass. The review page shows sampled states side by side plus the live widget.

**Blocked by:** 03, 05

**Status:** ready-for-agent

- [ ] One declaration per output names its states; fingerprinting, screenshots and review all follow from it
- [ ] Widgets expose a hook to set a given state, so headless Chrome (chromote) captures are deterministic
- [ ] Screenshots are taken only for Unreviewed states and never slow runs that only check expectations
- [ ] Agents review sampled states (start, middle, end at minimum) before the human sees them
- [ ] The review page shows the states and the live widget for hands-on review
- [ ] Demonstrated with the slider prototype output from 03
