---
name: readme-is-generated
description: Read BEFORE editing, writing, or fixing anything in README.md at the package root (other README.md files, e.g. testing/README.md, are fine to edit directly). The root README.md is a generated file.
---

# The root README.md is generated — never edit it by hand

`README.md` at the package root is generated from `README.Rmd` by knitr.
Any direct edit to it will be silently overwritten on the next render.

Instead:

1. Make the change in `README.Rmd`. Prose is plain markdown; code examples
   are executable knitr chunks — new example blocks get a labeled chunk
   (the label names the figure file) with options like `fig.width`,
   `fig.alt`, `eval = FALSE` (for don't-run examples), or `fig.keep` /
   `fig.show = "hold"` (for multi-plot chunks showing one image).
2. Re-render with:

   ```sh
   Rscript -e "devtools::build_readme()"
   ```

   This regenerates `README.md` and all `man/figures/README-*.png` figures
   (takes ~1 minute; the two 3-D plotly snapshots need Chrome/Edge).
3. Commit `README.Rmd`, `README.md`, and any changed figures together.

Prose-only changes still require the re-render — do not hand-copy the edit
into `README.md`, even if it seems faster.
