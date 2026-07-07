# CASE: gs_37_err_data_mismatch
# TYPE: console
# FUNC: geom_slice
# EXPECT: KNOWN ISSUE (missing check, dev_todo.Rmd: "Add error check to
#         geom_slice and slice_2d checking if the data being plotted in the
#         ggplot is the same as the data the lm was fit to"). A clear,
#         student-readable error saying the plotted data is not the data
#         `model` was fitted to. Currently geom_slice draws the (meaningless)
#         line over the unrelated data with no complaint at all, so this case
#         FAILs against a hand-written expected snapshot of the desired
#         behavior. When the check lands, accept its real wording with
#         'Rscript testing/run.R --update gs_37'.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 2 * x + rnorm(n)
fitted_data <- data.frame(x, y)
model <- lm(y ~ x, data = fitted_data)

# A different dataset that happens to share the column names.
other_data <- data.frame(x = runif(n, -10, 10), y = rnorm(n, 5, 3))

try_show(ggplot(other_data, aes(x, y)) +
           geom_point() +
           geom_slice(model))
