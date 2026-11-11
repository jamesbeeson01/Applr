# The behaviour inventory (spec: "Write, then salvage") and which cases cover
# it. The format is described in tests/suite/README.md, "Behaviour inventory".
# Cases cite entries with covers("<id>", ...), read here from the case file
# without running it.

inventory_path <- function(root = ".") file.path(root, "for_devs", "behaviour_inventory.yml")

# Flattens the inventory into one record per entry. Stops, listing every
# problem, when an entry has no ID or principle, or an ID is used twice.
read_inventory <- function(file) {
  raw <- yaml::read_yaml(file)
  groups <- list()
  entries <- list()
  for (section in c("functions", "shared")) {
    for (name in names(raw[[section]])) {
      g <- raw[[section]][[name]]
      family <- if (section == "shared") "shared behaviours" else g$family %||% name
      groups[[length(groups) + 1]] <- list(
        name = name, shared = section == "shared", family = family,
        purpose = g$purpose %||% "", functions = as.list(unlist(g$functions))
      )
      for (kind in c("behaviours", "edge_cases")) {
        for (e in g[[kind]]) {
          entries[[length(entries) + 1]] <- list(
            id = e$id %||% "", group = name, shared = section == "shared", family = family,
            kind = if (kind == "behaviours") "behaviour" else "edge case",
            principle = e$principle %||% "", source = e$source %||% "",
            options = as.list(unlist(e$options)), deferred = e$deferred %||% ""
          )
        }
      }
    }
  }
  ids <- vapply(entries, `[[`, "", "id")
  problems <- c(
    sprintf("an entry in '%s' has no valid id (lower case letters, digits, '.', '_', '-')",
            vapply(entries, `[[`, "", "group")[!grepl("^[a-z0-9][a-z0-9_.-]*$", ids)]),
    sprintf("'%s' has no principle", ids[!nzchar(trimws(vapply(entries, `[[`, "", "principle")))]),
    sprintf("'%s' is used more than once", unique(ids[duplicated(ids)]))
  )
  if (length(problems)) {
    stop("Behaviour inventory ", file, ":\n", paste0("  - ", problems, collapse = "\n"), call. = FALSE)
  }
  list(groups = groups, entries = entries)
}

# The inventory IDs a case file cites through covers(), in order.
case_covers <- function(file) {
  found <- character()
  walk <- function(x) {
    if (!is.call(x)) return()
    args <- as.list(x)[-1]
    if (identical(x[[1]], as.name("covers"))) {
      found <<- c(found, unlist(Filter(is.character, args)))
    }
    for (i in seq_along(args)) {
      if (!identical(args[[i]], quote(expr = ))) walk(args[[i]])
    }
  }
  for (e in parse(file, keep.source = FALSE)) walk(e)
  unique(found)
}

# One record per case file: the IDs it cites, any the inventory doesn't
# know, and its family, taken from the first function entry it cites (else
# the first shared one).
case_index <- function(case_dir, inventory) {
  ids <- vapply(inventory$entries, `[[`, "", "id")
  shared <- vapply(inventory$entries, `[[`, TRUE, "shared")
  family <- vapply(inventory$entries, `[[`, "", "family")
  files <- list.files(case_dir, pattern = "^test-case_.*\\.R$", full.names = TRUE)
  lapply(files, function(f) {
    cites <- case_covers(f)
    known <- match(cites[cites %in% ids], ids)
    first <- c(known[!shared[known]], known)[1]
    list(name = case_name(f), file = basename(f), covers = as.list(cites),
         unknown = as.list(setdiff(cites, ids)),
         family = if (is.na(first)) "not in the inventory" else family[first])
  })
}
