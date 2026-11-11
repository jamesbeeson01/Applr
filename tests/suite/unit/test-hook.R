# Human authority (spec: "Human authority"): agent writes to the decisions
# file are blocked, by a deny rule for file-edit tools and by the hook for
# shell tools, and the agent commands are not.

hook_script <- file.path(root, ".claude", "hooks", "protect_human_decisions.R")

run_hook <- function(tool, input) {
  f <- tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(list(tool_name = tool, tool_input = input), auto_unbox = TRUE), f)
  processx::run(file.path(R.home("bin"), "Rscript"), hook_script, stdin = f, error_on_status = FALSE)$status
}

test_that("the project settings deny file edits to the decisions file and hook every shell tool", {
  settings <- jsonlite::read_json(file.path(root, ".claude", "settings.json"))
  expect_true("Edit(tests/suite/human_decisions.json)" %in% unlist(settings$permissions$deny))
  hooks <- Filter(function(h) any(grepl("protect_human_decisions.R", unlist(h$hooks), fixed = TRUE)),
                  settings$hooks$PreToolUse)
  expect_length(hooks, 1)
  tools <- strsplit(hooks[[1]]$matcher, "|", fixed = TRUE)[[1]]
  expect_true(all(c("Bash", "PowerShell") %in% tools))
})

test_that("an edit or a shell write to the decisions file is blocked", {
  target <- file.path(root, "tests", "suite", "human_decisions.json")
  expect_equal(run_hook("Edit", list(file_path = target, old_string = "a", new_string = "b")), 2)
  expect_equal(run_hook("Write", list(file_path = target, content = "[]")), 2)
  expect_equal(run_hook("Bash", list(command = "echo '[]' > tests/suite/human_decisions.json")), 2)
  expect_equal(run_hook("PowerShell", list(command = "Set-Content tests\\suite\\Human_Decisions.json '[]'")), 2)
})

test_that("the agent commands, and files that only mention the decisions file, are allowed", {
  expect_equal(run_hook("Bash", list(command = "Rscript tests/suite/suite.R approve single_predictor_line/plot \"ok\"")), 0)
  expect_equal(run_hook("Write", list(file_path = file.path(root, "tests", "suite", "store.R"),
                                      content = "# human_decisions.json is written by the server")), 0)
  expect_equal(run_hook("Read", list(file_path = file.path(root, "tests", "suite", "human_decisions.json"))), 0)
})
