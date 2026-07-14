# gs_14 REFERENCE — mtcars, mpg ~ disp + hp + cyl, facet_wrap(~cyl), hp held at 110.
# One line per panel: cyl held at the panel value, disp over that panel's data range.
source("tests/reference/_ref_helpers.R")
model <- lm(mpg ~ disp + hp + cyl, data = mtcars)

ref <- do.call(rbind, lapply(sort(unique(mtcars$cyl)), function(cv) {
  d <- ref_slice(model, subset(mtcars, cyl == cv), "disp", held = list(hp = 110, cyl = cv))
  d$cyl <- cv
  d
}))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  facet_wrap(~cyl) +
  geom_line(data = ref, aes(disp, .pred), color = "steelblue", linewidth = 1) +
  labs(title = "gs_14 REFERENCE — mpg ~ disp + hp + cyl, facet_wrap(~cyl), hp=110",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_14_real_data_faceted.png", plot = p, width = 10, height = 4)
message("OK: tests/reference/gs_14_real_data_faceted.png")
