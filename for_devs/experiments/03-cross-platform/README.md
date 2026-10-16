# THROWAWAY: cross-platform fingerprint experiment (ticket 03)

Not part of the suite. It answers one question: do fingerprints, as the spec defines them, match across Windows, macOS and Linux? It covers every output type: static ggplot, base graphics, condition text, plotly JSON, a slider payload with its background, and animation frame data. Delete this folder and `.github/workflows/xplat-experiment.yaml` once the spec's deferred decisions are settled.

| File | Role |
|---|---|
| `fingerprint_all.R` | Fingerprints 13 old cases, `scatter_3d`, the P5 slider demos A and B, and a 12-frame `hp` sweep animation. Writes `results/<platform>/`. |
| `slider_p5.R` | A trimmed copy of the P5 prototype's payload build. `scratch/` is gitignored, so CI can't see the original. |
| `pin_versions.R` / `versions.csv` | The maintainer's package versions, which every machine installs. |
| `install_pinned.R` | Installs `versions.csv` with pak, and fails if any version differs. |
| `compare.R` | Compares every platform with the reference and writes `results/comparison.md`. |

The workflow runs on pushes to `test-suite-revision`, and only on the fork `jamesbeeson01/Applr`. It runs on Windows, macOS and Ubuntu with R 4.5.3, and uploads each platform's results as an artifact.

```sh
Rscript for_devs/experiments/03-cross-platform/fingerprint_all.R   # local run
gh run download <run-id> -R jamesbeeson01/Applr -D for_devs/experiments/03-cross-platform/results --pattern "xplat-*"
Rscript for_devs/experiments/03-cross-platform/compare.R
```

The download puts each platform under `results/xplat-<platform>/`.
