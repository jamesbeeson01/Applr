# gt_07 REFERENCE — y ~ x * g + x2 with color = g: four lines (two per group),
# each labeled "x2: 0"/"x2: 3" in its own line's color. Lines span each
# group's x range (per the decisions.Rmd group-range rule).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 80
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B"), n, replace = TRUE))
x2 <- runif(n, 0, 4)
y <- x * ifelse(g == "A", 1, 2) + ifelse(g == "A", 0, 8) + 3 * x2 + rnorm(n)
dat <- data.frame(x, g, x2, y)
model <- lm(y ~ x * g + x2, data = dat)

combos <- expand.grid(g = levels(dat$g), x2 = c(0, 3), stringsAsFactors = FALSE)
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

# Constant gap past the line end; x-expansion sized by the longest label.
nx <- 0.012 * diff(range(dat$x))
ex <- 0.025 + 0.013 * max(nchar(ends$label))

p <- ggplot(dat, aes(x, y, color = g)) +
  geom_point(alpha = 0.5) +
  geom_line(data = lines, aes(x, .pred, color = g, group = id), linewidth = 1) +
  geom_text(data = ends, aes(x, .pred, label = label, color = g),
            hjust = 0, vjust = 0.5, nudge_x = nx, show.legend = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(0.05, ex))) +
  labs(title = "gt_07 REFERENCE — labels inherit each line's group color",
       subtitle = "Ground truth via predict() + geom_text (no Applr)")

ggsave("tests/reference/gt_07_color_grouped.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gt_07_color_grouped.png")
