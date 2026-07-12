# CASE: se_04_grouped_interaction
# TYPE: widget
# FUNC: slice_explore
# EXPECT: Three colored point groups (cyl 4/6/8, with a legend) each with its
#         own line of a DIFFERENT slope (disp*cyl interaction), matching the
#         static autoplot with mapping = aes(color = factor(cyl)). cyl is
#         pinned per color group, so there is only ONE slider — hp — and
#         dragging it moves all three lines together (hp is additive).
#         Console: one Sliders message for hp only.

source("testing/_setup.R")

model <- lm(mpg ~ disp * cyl + hp, data = mtcars)

slice_explore(model, mapping = aes(color = factor(cyl)))
