# Claude Code PreToolUse hook (spec: "Human authority"). Blocks any agent
# write to tests/suite/human_decisions.json, which only the review server
# writes: file-edit tools whose target is that file, and shell commands that
# name it. Exit status 2 blocks the tool call and shows the message to the
# agent. A guardrail against careless agents, not a lock.

input <- tryCatch(
  jsonlite::fromJSON(paste(readLines(file("stdin"), warn = FALSE), collapse = "\n"),
                     simplifyVector = FALSE),
  error = function(e) list()
)
tool <- input$tool_name %||% ""
ti <- input$tool_input %||% list()
target <- if (tool %in% c("Bash", "PowerShell")) {
  ti$command
} else if (tool %in% c("Edit", "MultiEdit", "Write", "NotebookEdit")) {
  c(ti$file_path, ti$notebook_path)
}

if (any(grepl("human_decisions\\.json", unlist(target), ignore.case = TRUE))) {
  message("Blocked: tests/suite/human_decisions.json holds the maintainer's own review decisions. ",
          "Only the review server writes it, when the maintainer approves or rejects on the review page. ",
          "Use `Rscript tests/suite/suite.R approve|reject <id> \"<note>\"` for agent decisions, ",
          "and ask the maintainer to review on the page (Rscript tests/suite/review.R).")
  quit(save = "no", status = 2)
}
