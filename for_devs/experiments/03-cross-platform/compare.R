# THROWAWAY (ticket 03). Compares every platform in results/ against the
# reference platform and writes results/comparison.md.
#
#   Rscript for_devs/experiments/03-cross-platform/compare.R [reference]

exp_dir <- "for_devs/experiments/03-cross-platform"
res_dir <- file.path(exp_dir, "results")
ref <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(ref)) ref <- "local-windows"

platforms <- c(ref, setdiff(list.dirs(res_dir, full.names = FALSE, recursive = FALSE), ref))
fps <- lapply(setNames(platforms, platforms), function(p) read.csv(file.path(res_dir, p, "fingerprints.csv")))
base <- fps[[ref]]
whole <- base[base$part == "(all)", ]

form_lines <- function(p, output) {
  file <- file.path(res_dir, p, "forms", paste0(output, ".txt"))
  if (file.exists(file)) readLines(file, warn = FALSE) else "<no such output>"
}

# First few differing lines between two forms, aligned by line number; enough
# to name a cause, not a full diff.
first_diffs <- function(a, b, n = 3) {
  len <- max(length(a), length(b))
  a <- c(a, rep("<missing>", len - length(a)))
  b <- c(b, rep("<missing>", len - length(b)))
  hit <- head(which(a != b), n)
  clip <- function(s) if (nchar(s) > 160) paste0(substr(s, 1, 160), "...") else s
  vapply(hit, function(i) sprintf("line %d: `%s` vs `%s`", i, clip(a[i]), clip(b[i])), "")
}

out <- c("# Cross-platform fingerprint results", "",
         sprintf("Reference platform: `%s`. Generated %s.", ref, format(Sys.time(), "%Y-%m-%d %H:%M")), "")

# Summary: per output type, how many outputs match the reference.
types <- unique(whole$type)
summary_rows <- vapply(types, function(t) {
  outs <- whole$output[whole$type == t]
  cells <- vapply(platforms[-1], function(p) {
    other <- fps[[p]]
    got <- other$hash[match(paste(outs, "(all)"), paste(other$output, other$part))]
    want <- whole$hash[match(outs, whole$output)]
    k <- sum(got == want, na.rm = TRUE)
    sprintf("%s %d/%d", if (k == length(outs)) "match" else "**no match**", k, length(outs))
  }, "")
  paste0("| ", t, " | ", paste(cells, collapse = " | "), " |")
}, "")
out <- c(out, "## Matches per output type", "",
         paste0("| Output type | ", paste(platforms[-1], collapse = " | "), " |"),
         paste0("|---|", paste(rep("---", length(platforms) - 1), collapse = "|"), "|"),
         summary_rows, "")

# Detail: every mismatching output, which parts differ, and where.
out <- c(out, "## Mismatches", "")
any_mismatch <- FALSE
for (p in platforms[-1]) {
  other <- fps[[p]]
  for (o in whole$output) {
    a <- base[base$output == o, ]
    b <- other[other$output == o, ]
    if (identical(a$hash[a$part == "(all)"], b$hash[b$part == "(all)"])) next
    any_mismatch <- TRUE
    parts <- setdiff(a$part, "(all)")
    differ <- parts[a$hash[match(parts, a$part)] != b$hash[match(parts, b$part)] |
                    is.na(b$hash[match(parts, b$part)])]
    out <- c(out, sprintf("### `%s` on %s", o, p), "",
             sprintf("Parts that differ: %s", paste(differ, collapse = ", ")), "",
             paste0("- ", first_diffs(form_lines(ref, o), form_lines(p, o))), "")
  }
}
if (!any_mismatch) out <- c(out, "None.", "")

# Environment: pinned versions and the numeric libraries each platform used.
pins <- read.csv(file.path(exp_dir, "versions.csv"))
out <- c(out, "## Environments", "")
for (p in platforms) {
  inst <- read.csv(file.path(res_dir, p, "installed.csv"))
  got <- inst$Version[match(pins$package, inst$Package)]
  off <- pins$package[is.na(got) | got != pins$version]
  sess <- readLines(file.path(res_dir, p, "session.txt"), warn = FALSE)
  keep <- grep("^(R version|Platform|Running under|BLAS|LAPACK|La_library|La_version|locale|l10n_info)", sess, value = TRUE)
  out <- c(out, sprintf("### %s", p), "",
           sprintf("Pinned versions: %s", if (length(off)) paste("**differ:**", paste(off, collapse = ", ")) else "all match"),
           "", "```", keep, "```", "")
}

writeLines(out, file.path(res_dir, "comparison.md"))
cat(paste(summary_rows, collapse = "\n"), "\n")
