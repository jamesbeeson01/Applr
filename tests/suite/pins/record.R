# Records this machine's versions of everything the CI check loads, so every
# runner installs exactly these (spec: "CI"; H7). Run from the package root
# after updating packages, then re-run the suite:
#   Rscript tests/suite/pins/record.R

roots <- c("ggplot2", "plotly", "rlang", "pkgload", "testthat", "vdiffr", "digest",
           "jsonlite", "svglite", "cli", "htmlwidgets")
ip <- installed.packages()
deps <- tools::package_dependencies(roots, db = ip, recursive = TRUE,
                                    which = c("Depends", "Imports", "LinkingTo"))
pkgs <- sort(unique(c(roots, unlist(deps))))
pkgs <- pkgs[!ip[pkgs, "Priority"] %in% c("base", "recommended")]
write.csv(data.frame(package = pkgs, version = ip[pkgs, "Version"]),
          "tests/suite/pins/versions.csv", row.names = FALSE)
cat(sprintf("R %s, %d packages pinned\n", getRversion(), length(pkgs)))
