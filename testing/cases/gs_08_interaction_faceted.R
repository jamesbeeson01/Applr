# gs_08_interaction_faceted.R
# EXPECT: Three facet panels (x_switch = 0, 1, 2), each showing the scatter
#         for that group plus a fitted line appropriate to that x_switch value.
#         Panel 0: flat line (slope~0). Panel 1: slope~1. Panel 2: slope~2.
#         geom_slice() should detect the facet variable and slice accordingly.
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch + rnorm(n)
model <- lm(y ~ x:x_switch)

p <- ggplot(data.frame(x, y, x_switch), aes(x, y)) +
  geom_point(color = "steelblue") +
  facet_wrap(~x_switch) +
  geom_slice(model) +
  labs(title = "gs_08: Interaction model with facet_wrap(~x_switch)",
       subtitle = "EXPECT: Three panels, each with a correctly-sliced fitted line")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_08_interaction_faceted.png", plot = p, width = 10, height = 4)
message("OK: testing/output/gs_08_interaction_faceted.png")
