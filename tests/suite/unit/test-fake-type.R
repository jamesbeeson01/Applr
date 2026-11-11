# A deliberately odd output type, defined only here: a travel itinerary with
# four parts, five states (one per day) and an HTML view per state. It goes
# from run to the review page's data through the core unchanged, and gets the
# shared trust tests by filling in the contract.

fake_type <- quote(register_output_type(
  "itinerary",
  detect = function(x) inherits(x, "itinerary"),
  states = function(declared) declared %||% stats::setNames(as.list(1:5), paste0("day", 1:5)),
  serialise = function(trip, states) list(
    parts = list(
      title = trip$title,
      stops = canonical_json(trip$stops),
      legend = names(trip$legend),
      budget = format(trip$budget, nsmall = 2)
    ),
    view = trip
  ),
  render = function(trip, day, file, live) {
    stops <- trip$stops[trip$stops$day == day, "place"]
    writeLines(c("<!doctype html><meta charset='utf-8'>",
                 sprintf("<h1>%s, day %d</h1>", trip$title, day),
                 sprintf("<li>%s</li>", stops)), file)
  },
  view = "states",
  format = "html",
  mutations = list(
    title = function(x) { x$object$title <- "Elsewhere"; x },
    stop = function(x) { x$object$stops$place[1] <- "Detour"; x },
    budget = function(x) { x$object$budget <- x$object$budget + 0.01; x }
  )
))

trip_case <- c(
  "trip <- structure(list(",
  "  title = 'Coast', budget = 1200,",
  "  stops = data.frame(day = rep(1:5, each = 2), place = paste('stop', 1:10)),",
  "  legend = c(walk = '#1b9e77', drive = '#d95f02')",
  "), class = 'itinerary')",
  "judged_output('trip', trip)",
  "long <- trip; long$budget <- 3000",
  "judged_output('trip_long', long)",
  "test_that('every day has two stops', expect_equal(as.vector(table(trip$stops$day)), rep(2, 5)))"
)

trip_dir <- function() {
  dir <- tempfile("case")
  dir.create(dir)
  file.copy(file.path(case_dir, "helper-judged.R"), dir)
  writeLines(trip_case, file.path(dir, "test-case_trip.R"))
  dir
}

test_that("an unforeseen type goes from run to the review page's data", {
  eval(fake_type)
  withr::defer(unregister_output_type("itinerary"))
  paths <- temp_paths()
  dir <- trip_dir()

  report <- run_suite(dir, paths)
  id <- "trip/trip"
  expect_equal(report[[id]], "Unreviewed (new fingerprint)")
  rec <- read_state(paths)[[id]]
  expect_equal(rec$type, "itinerary")
  expect_named(rec$parts, c("title", "stops", "legend", "budget"))
  expect_equal(unlist(rec$states), paste0("day", 1:5))
  form <- readLines(file.path(paths$forms, "trip__trip.txt"))
  expect_equal(grep("^--- ", form, value = TRUE), paste("---", c("title", "stops", "legend", "budget")))

  agent_decide(id, "approve", "Five days, two stops each.", paths)
  expect_equal(read_state(paths)[[id]]$status, "Agent approved")

  page <- review_page_data(paths)[[id]]
  expect_equal(page$view, "states")
  expect_equal(page$status, "Agent approved")
  expect_equal(page$agent_note, "Five days, two stops each.")
  expect_equal(page$parts, c("title", "stops", "legend", "budget"))
  expect_equal(page$states$name, paste0("day", 1:5))
  expect_true(all(file.exists(page$states$file)))
  expect_match(readLines(page$states$file[3]), "Coast, day 3", all = FALSE)
  expect_true(is.na(page$live))

  # The review page reads it from the server, and the human approves it there.
  app <- test_app(paths, dir)
  data <- json_body(call_app(app, "/api/data"))
  out <- Filter(function(o) o$id == id, data$outputs)[[1]]
  expect_equal(vapply(out$states, `[[`, "", "name"), paste0("day", 1:5))
  day3 <- call_app(app, out$states[[3]]$url)
  expect_equal(day3$status, 200L)
  expect_match(rawToChar(day3$body), "Coast, day 3")

  res <- call_app(app, "/api/decide", method = "POST",
                  body = jsonlite::toJSON(list(id = id, decision = "approve", fingerprint = out$fingerprint),
                                          auto_unbox = TRUE))
  expect_equal(res$status, 200L)
  out <- Filter(function(o) o$id == id, json_body(call_app(app, "/api/data"))$outputs)[[1]]
  expect_equal(out$status, "Human approved")
  expect_false(any(vapply(out$states, function(s) is.null(s$approved_url), TRUE)))
})

test_that("the unforeseen type gets the shared trust tests", {
  eval(fake_type)
  withr::defer(unregister_output_type("itinerary"))
  case <- file.path(trip_dir(), "test-case_trip.R")
  entries <- type_entries("itinerary", case)
  expect_complete("itinerary", entries)
  expect_sensitive("itinerary", entries[["trip/trip"]])
  expect_stable("itinerary", case, setup = deparse(fake_type))
})
