# THROWAWAY (ticket 03). Installs versions.csv exactly, then fails if any
# installed version differs.

pins <- read.csv("for_devs/experiments/03-cross-platform/versions.csv")
pak::pkg_install(paste0(pins$package, "@", pins$version), upgrade = FALSE, ask = FALSE)
got <- vapply(pins$package, function(p) as.character(packageVersion(p)), "")
bad <- pins[got != pins$version, ]
if (nrow(bad)) {
  print(cbind(bad, installed = got[got != pins$version]))
  stop("installed versions differ from versions.csv")
}
cat(nrow(pins), "packages at pinned versions\n")
