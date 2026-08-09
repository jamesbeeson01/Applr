# gt_14 REFERENCE — y ~ x * g + x2 with color = g on a narrow 5x5 in device:
# four lines (two per group), each labeled "x2: 0.25"/"x2: 4.5" in its own
# line's color, all of them clear of the panel's right border. Lines span each
# group's x range (per the decisions.Rmd group-range rule).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 80
x <- runif(n, -10, 10)
g <- sample(c("A", "B"), n, replace = TRUE)
x2 <- runif(n, 0, 5)
y <- x + ifelse(g == "A", 0, 6) + ifelse(g == "A", 1, -0.5) * x + 1.5 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

combos <- expand.grid(g = sort(unique(dat$g)), x2 = c(0.25, 4.5),
                      stringsAsFactors = FALSE)
lines <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
  gi <- combos$g[i]
  s <- ref_slice(model, dat[dat$g == gi, ], "x",
                 held = list(g = gi, x2 = combos$x2[i]))
  s$g <- gi
  s$label <- paste0("x2: ", combos$x2[i])
  s$id <- i
  s
}))
ends <- do.call(rbind, lapply(split(lines, lines$id),
                              function(d) d[which.max(d$x), ]))

# Constant gap past the line end; x-expansion sized by the widest label, for
# the 5 in wide device this reference is drawn on (the narrow panel is the
# whole point of the case, so the width is passed explicitly).
nx <- 0.024 * diff(range(dat$x))
ex <- ref_text_expand(ends$label, device_in = 5)

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point() +
  geom_line(data = lines, aes(x, .pred, color = g, group = id), linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label, color = g),
            hjust = 0, vjust = 0.5, nudge_x = nx, show.legend = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_14 REFERENCE — labels fit a narrow panel",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("tests/reference/gt_14_narrow_panel_labels_fit.png", plot = p,
       width = 5, height = 5)
message("OK: tests/reference/gt_14_narrow_panel_labels_fit.png")
