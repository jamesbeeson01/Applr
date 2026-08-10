# CASE: sb_16_ambiguous_levels_no_fallback
# TYPE: visual
# SIZE: 4.5x4.5
# FUNC: geom_slice_subtitle
# EXPECT: The guard on the sb_15 fallback. Same width as sb_15 and the same
#         shape of model — an interaction term too wide to fit however it is
#         broken — so the fallback would fire here too, except that
#         `treatment_grade` and `facility_tier` BOTH print a "High" term.
#         Shortening would give two `[High]` terms that cannot be told apart,
#         losing information rather than just space, so it is refused: every
#         factor term stays spelled out as (treatment_grade="High") and
#         (facility_tier="High"), and the subtitle wraps as far as it can and
#         then runs off the plot. Overflow is the honest outcome — the
#         alternative was a subtitle that fits but cannot be read. Note that
#         "High" is NOT the reference level of either factor; the guard tests
#         the labels actually printed, so two factors sharing a reference
#         level (which never reaches an equation term) would not trip it.

source("tests/_setup.R")
set.seed(42)

n <- 90
d <- data.frame(
  measurement_width = runif(n, 0, 10),
  treatment_grade   = factor(sample(c("Control", "High"), n, replace = TRUE)),
  facility_tier     = factor(sample(c("Baseline", "High"), n, replace = TRUE))
)
d$outcome_score <- 2 + 0.6 * d$measurement_width +
  3 * (d$treatment_grade == "High") - 2 * (d$facility_tier == "High") +
  0.4 * d$measurement_width * (d$treatment_grade == "High") + rnorm(n)

model <- lm(outcome_score ~ measurement_width * treatment_grade +
              facility_tier, data = d)

p <- ggplot(d, aes(measurement_width, outcome_score, color = treatment_grade)) +
  geom_point(size = 0.8) +
  geom_slice(model) +
  geom_slice_subtitle() +
  labs(title = "sb_16: Shared level names")
p
