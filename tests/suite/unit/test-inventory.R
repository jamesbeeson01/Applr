# The behaviour inventory's format, and the coverage cases declare with
# covers().

write_yaml_lines <- function(lines) {
  f <- tempfile(fileext = ".yml")
  writeLines(lines, f)
  f
}

inventory_lines <- c(
  "functions:",
  "  geom_slice:",
  "    family: layers",
  "    behaviours:",
  "      - id: gs.line",
  "        principle: The line is the prediction.",
  "    edge_cases:",
  "      - id: gs.factor",
  "        principle: Factors are imputed as a level.",
  "        options: [one, two]",
  "        deferred: Package bug.",
  "shared:",
  "  imputation:",
  "    functions: [geom_slice, slice_2d]",
  "    behaviours:",
  "      - id: shared.message",
  "        principle: Each imputed predictor gets a message."
)

test_that("the inventory flattens to one entry per behaviour, with its group and family", {
  inv <- read_inventory(write_yaml_lines(inventory_lines))
  ids <- vapply(inv$entries, `[[`, "", "id")
  expect_equal(ids, c("gs.line", "gs.factor", "shared.message"))
  e <- inv$entries[[2]]
  expect_equal(e[c("group", "family", "kind", "deferred")],
               list(group = "geom_slice", family = "layers", kind = "edge case", deferred = "Package bug."))
  expect_equal(unlist(e$options), c("one", "two"))
  expect_true(inv$entries[[3]]$shared)
  expect_equal(unlist(inv$groups[[2]]$functions), c("geom_slice", "slice_2d"))
})

test_that("an inventory with a reused ID, a missing principle or a bad ID is refused", {
  dup <- c(inventory_lines, "      - id: gs.line", "        principle: Again.")
  expect_error(read_inventory(write_yaml_lines(dup)), "'gs.line' is used more than once")
  nop <- sub("principle: The line is the prediction.", "source: x", inventory_lines, fixed = TRUE)
  expect_error(read_inventory(write_yaml_lines(nop)), "'gs.line' has no principle")
  bad <- sub("id: gs.line", "id: GS Line", inventory_lines, fixed = TRUE)
  expect_error(read_inventory(write_yaml_lines(bad)), "no valid id")
})

test_that("covers() is read from anywhere in a case file, without running it", {
  f <- tempfile(fileext = ".R")
  writeLines(c("covers('gs.line')", "x <- mtcars[, 1]",
               "test_that('t', { covers('shared.message', 'gs.line'); stop('never run') })"), f)
  expect_equal(case_covers(f), c("gs.line", "shared.message"))
})

test_that("each case gets its family from the first function entry it cites, and unknown IDs are flagged", {
  inv <- read_inventory(write_yaml_lines(inventory_lines))
  dir <- tempfile("case"); dir.create(dir)
  writeLines("covers('shared.message', 'gs.line')", file.path(dir, "test-case_a.R"))
  writeLines("covers('shared.message', 'nope')", file.path(dir, "test-case_b.R"))
  writeLines("1", file.path(dir, "test-case_c.R"))
  idx <- case_index(dir, inv)
  expect_equal(vapply(idx, `[[`, "", "family"), c("layers", "shared behaviours", "not in the inventory"))
  expect_equal(unlist(idx[[2]]$unknown), "nope")
})

test_that("the real inventory parses and every case cites only entries it has", {
  inv <- read_inventory(inventory_path(root))
  idx <- case_index(case_dir, inv)
  for (case in idx) expect_length(case$unknown, 0)
})
