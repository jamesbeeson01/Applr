# Render the figures embedded in README.md.
#
# Run from the package root:
#   Rscript scripts/render_readme_plots.R
#
# Output goes to man/figures/README-*.png. Each figure mirrors a code chunk
# in README.md — keep the code here in sync with the chunk it illustrates.
# The 3-D plotly figures are snapshotted with webshot2 (needs Chrome/Edge).

devtools::load_all(".", quiet = TRUE)
library(ggplot2)

fig_dir <- "man/figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# --- helpers ---------------------------------------------------------------

save_gg <- function(name, plot, width = 6, height = 4) {
  path <- file.path(fig_dir, paste0("README-", name, ".png"))
  ragg::agg_png(path, width = width, height = height, units = "in", res = 150)
  print(plot)
  dev.off()
  message("wrote ", path)
}

save_base <- function(name, expr, width = 6, height = 4) {
  path <- file.path(fig_dir, paste0("README-", name, ".png"))
  ragg::agg_png(path, width = width, height = height, units = "in", res = 150)
  eval(expr)
  dev.off()
  message("wrote ", path)
}

save_plotly <- function(name, widget, width = 800, height = 550) {
  path <- file.path(fig_dir, paste0("README-", name, ".png"))
  html <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(widget, html, selfcontained = TRUE)
  webshot2::webshot(html, path, vwidth = width, vheight = height, delay = 2)
  unlink(html)
  message("wrote ", path)
}

# --- Quick start -------------------------------------------------------------

model <- lm(mpg ~ disp + hp, data = mtcars)
# The two quick-start plots (autoplot and the hand-built geom_slice ggplot)
# are visually identical, so only one figure is rendered for both.
save_gg("quickstart-autoplot", autoplot(model))

# --- geom_slice(): facets ----------------------------------------------------

model <- lm(mpg ~ disp + hp + cyl, data = mtcars)
save_gg("facets",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    facet_wrap(~cyl) +
    geom_slice(model, predict_vars = list(hp = 110),
               color = "steelblue", linewidth = 1),
  width = 7)

# --- predict_vars: several slices --------------------------------------------

model <- lm(mpg ~ disp + hp, data = mtcars)
save_gg("predict-vars",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model, predict_vars = list(hp = c(66, 123, 335))))

# --- intervals ----------------------------------------------------------------

save_gg("interval",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model, interval = "prediction"))

# --- projection band -----------------------------------------------------------

save_gg("band",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model, band = "hp", predict_vars = list(hp = c(66, 335))))

# --- transformed response -------------------------------------------------------

log_model <- lm(log(mpg) ~ disp + hp, data = mtcars)
save_gg("back-transform",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(log_model))

# --- grouping -------------------------------------------------------------------

cyl_model <- lm(mpg ~ disp + factor(cyl), data = mtcars)
save_gg("grouping",
  ggplot(mtcars, aes(disp, mpg, color = factor(cyl))) +
    geom_point() +
    geom_slice(cyl_model))

# --- geom_slice_text() ------------------------------------------------------------

save_gg("slice-text",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model, predict_vars = list(hp = c(66, 123, 335))) +
    geom_slice_text(),
  width = 7.5)

# --- geom_slice_subtitle() ----------------------------------------------------------

save_gg("slice-subtitle",
  ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    geom_slice(model, predict_vars = list(hp = 110)) +
    geom_slice_subtitle())

# --- autoplot() -----------------------------------------------------------------------

save_gg("autoplot",
  autoplot(lm(mpg ~ disp + hp, data = mtcars),
           predict_vars = list(hp = 110), interval = "confidence") +
    labs(title = "Slice at hp = 110"))

save_plotly("autoplot-3d",
  autoplot(lm(mpg ~ disp + hp, data = mtcars), type = "3d"))

# --- slice_2d() -------------------------------------------------------------------------

save_base("slice-2d", quote(slice_2d(model)))

# --- add_slice_2d() ------------------------------------------------------------------------

save_base("add-slice-2d", quote({
  plot(mpg ~ disp, data = mtcars)
  add_slice_2d(model, hp = min(mtcars$hp), col = "blue")
  add_slice_2d(model, hp = max(mtcars$hp), col = "red", lty = 2)
}))

# --- scatter_3d() -----------------------------------------------------------------------------

save_plotly("scatter-3d",
  scatter_3d(model, colors = c("blue", "yellow")))

# --- diagnose() ----------------------------------------------------------------------------------

save_base("diagnose", quote(diagnose(lm(mpg ~ wt, data = mtcars))),
          width = 8, height = 3)

# --- theme_lc() ------------------------------------------------------------------------------------

save_gg("theme-lc",
  ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme_lc())

message("done.")
