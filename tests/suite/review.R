# Starts the review page on a local server and opens it. From the package
# root, either
#   Rscript tests/suite/review.R [port]     (Ctrl+C to stop)
# or, in an R session, source("tests/suite/review.R"), which leaves the
# server running in the background until stop_review_server().

source("tests/suite/load.R")
load_suite("tests/suite")

port <- suppressWarnings(as.integer(commandArgs(trailingOnly = TRUE)[1]))
if (is.na(port)) port <- review_port()
start_review_server(port, open = TRUE)

if (!interactive()) {
  message("Serving until Ctrl+C.")
  repeat httpuv::service(250)
}
