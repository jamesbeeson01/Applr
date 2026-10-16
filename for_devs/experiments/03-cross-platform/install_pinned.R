# THROWAWAY (ticket 03). Installs versions.csv exactly, then fails if any
# installed version differs.

pins <- read.csv("for_devs/experiments/03-cross-platform/versions.csv")
pak::pkg_install(paste0(pins$package, "@", pins$version), upgrade = FALSE, ask = FALSE)
got <- vapply(pins$package, function(p) as.character(packageVersion(p)), "")
same <- mapply(function(a, b) package_version(a) == package_version(b), got, pins$version)
bad <- pins[!same, ]
if (nrow(bad)) {
  print(cbind(bad, installed = got[!same]))
  stop("installed versions differ from versions.csv")
}
cat(nrow(pins), "packages at pinned versions\n")
