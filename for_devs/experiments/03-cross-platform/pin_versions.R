# THROWAWAY (ticket 03). Records this machine's versions of everything the
# experiment loads, so every other machine installs exactly these.
#
#   Rscript for_devs/experiments/03-cross-platform/pin_versions.R

roots <- c("ggplot2", "plotly", "rlang", "pkgload", "vdiffr", "digest",
           "jsonlite", "svglite", "cli", "htmlwidgets")
ip <- installed.packages()
deps <- tools::package_dependencies(roots, db = ip, recursive = TRUE,
                                    which = c("Depends", "Imports", "LinkingTo"))
pkgs <- sort(unique(c(roots, unlist(deps))))
pkgs <- pkgs[!ip[pkgs, "Priority"] %in% c("base", "recommended")]
write.csv(data.frame(package = pkgs, version = ip[pkgs, "Version"]),
          "for_devs/experiments/03-cross-platform/versions.csv", row.names = FALSE)
cat(sprintf("R %s, %d packages pinned\n", getRversion(), length(pkgs)))
