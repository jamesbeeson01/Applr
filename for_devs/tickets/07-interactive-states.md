# 07: Interactive states (infrastructure)

**What to build:** Support for judged outputs with several states. A case declares an interactive output's states (slider positions, camera presets). The output gets one fingerprint from its serialised parts (payload, background, shell), and deterministic screenshots of its states are captured only when it is Unreviewed, so agents can take a first pass. The review page shows sampled states side by side plus the live widget.

**Blocked by:** 03, 05

**Status:** ready-for-agent

- [ ] One declaration per output names its serialised parts and its states; fingerprinting, screenshots and review all follow from it
- [ ] The widget is built from the hashed payload itself, with the completeness, sensitivity and stability tests from the spec's *Trusting a fingerprint*
- [ ] Widgets expose a hook to set a given state, so headless Chrome (chromote) captures are deterministic
- [ ] Screenshots are taken only for Unreviewed outputs and never slow runs that only check expectations or fingerprints
- [ ] A state whose screenshot is unchanged since the last approval is marked so, letting a reviewer skip it
- [ ] Agents review sampled states (start, middle, end at minimum) before the human sees them
- [ ] The review page shows the states and the live widget for hands-on review
- [ ] Demonstrated with the slider prototype output from 03
