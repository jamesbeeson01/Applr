# build_all.R — render every geom_slice / geom_slice_text reference image.
# Run from the package root:
#   Rscript testing/reference/build_all.R

cases <- sort(list.files("testing/reference", pattern = "^(gs|gt|sb|cp|se)_.*\\.R$", full.names = TRUE))
cat(sprintf("Building %d reference images...\n\n", length(cases)))

for (f in cases) {
  cat(sprintf("  %-44s", basename(f)))
  res <- tryCatch({ source(f, local = new.env()); "OK" },
                  error = function(e) paste("FAIL:", conditionMessage(e)))
  cat(res, "\n")
}
