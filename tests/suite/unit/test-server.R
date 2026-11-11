# The review server's rules: what it serves, and that a decision reaches
# human_decisions.json only as JSON from the page, checked by
# review_transition().

served <- function() {
  paths <- temp_paths()
  dir <- case_copy()
  run_suite(dir, paths)
  agent_decide(id, "approve", "Line follows the points.", paths)
  list(paths = paths, app = test_app(paths, dir), fp = read_state(paths)[[id]]$fingerprint)
}
decide_body <- function(...) jsonlite::toJSON(list(id = id, ...), auto_unbox = TRUE)

test_that("the page, its data and the views are served", {
  s <- served()
  page <- call_app(s$app, "/")
  expect_equal(page$status, 200L)
  expect_match(page$headers[["Content-Type"]], "text/html")
  expect_match(rawToChar(page$body), "/page/app.js", fixed = TRUE)
  expect_equal(call_app(s$app, "/page/app.js")$status, 200L)

  data <- json_body(call_app(s$app, "/api/data"))
  out <- data$outputs[[1]]
  expect_equal(out[c("id", "status", "view", "agent_note")],
               list(id = id, status = "Agent approved", view = "image", agent_note = "Line follows the points."))
  png <- call_app(s$app, out$states[[1]]$url)
  expect_equal(png$headers[["Content-Type"]], "image/png")
  expect_equal(png$body[2:4], charToRaw("PNG"))
  expect_equal(data$cases[[1]]$name, "single_predictor_line")
  expect_true(length(data$inventory$entries) > 0)

  form <- json_body(call_app(s$app, "/api/form", query = paste0("?id=", utils::URLencode(id, reserved = TRUE))))
  expect_true(length(form$form) > 10)
  expect_null(form$diff)
})

test_that("a decision from the page is checked and written to the decisions file", {
  s <- served()
  res <- call_app(s$app, "/api/decide", method = "POST", body = decide_body(decision = "approve", fingerprint = s$fp),
                  origin = "http://127.0.0.1:7654")
  expect_equal(res$status, 200L)
  expect_equal(json_body(res)$status, "Human approved")
  expect_equal(read_decisions(s$paths)[[1]]$decision, "approve")
  again <- call_app(s$app, "/api/decide", method = "POST", body = decide_body(decision = "approve", fingerprint = s$fp))
  expect_equal(again$status, 409L)
  expect_length(read_decisions(s$paths), 1)
})

test_that("a rejection without a note, or on a stale page, is refused", {
  s <- served()
  expect_equal(call_app(s$app, "/api/decide", method = "POST",
                        body = decide_body(decision = "reject", note = "", fingerprint = s$fp))$status, 409L)
  expect_equal(call_app(s$app, "/api/decide", method = "POST",
                        body = decide_body(decision = "approve", fingerprint = "000000000000"))$status, 409L)
  expect_false(file.exists(s$paths$decisions))
  ok <- call_app(s$app, "/api/decide", method = "POST",
                 body = decide_body(decision = "reject", note = "Too tight.", fingerprint = s$fp))
  expect_equal(json_body(ok)$status, "Rejected")
})

test_that("only JSON from the page's own origin is accepted", {
  s <- served()
  body <- decide_body(decision = "approve", fingerprint = s$fp)
  expect_equal(call_app(s$app, "/api/decide", method = "POST", body = body,
                        type = "application/x-www-form-urlencoded")$status, 415L)
  expect_equal(call_app(s$app, "/api/decide", method = "POST", body = body,
                        origin = "http://evil.example")$status, 403L)
  expect_equal(call_app(s$app, "/api/decide", method = "POST", body = body,
                        host = "evil.example:7654", origin = "http://evil.example:7654")$status, 403L)
  expect_equal(call_app(s$app, "/api/decide", method = "GET", body = body)$status, 404L)
  expect_false(file.exists(s$paths$decisions))
})

test_that("nothing outside the page and view folders is served", {
  s <- served()
  expect_true(file.exists(s$paths$state))
  expect_equal(call_app(s$app, "/views/../review_state.json")$status, 404L)
  expect_equal(call_app(s$app, "/views/%2e%2e/review_state.json")$status, 404L)
  expect_equal(call_app(s$app, "/page/../store.R")$status, 404L)
  expect_equal(call_app(s$app, "/views/")$status, 404L)
})

test_that("deep links name one output or one page", {
  expect_equal(review_url(id, port = 7000), "http://127.0.0.1:7000/?output=single_predictor_line%2Fplot")
  expect_equal(review_url(view = "overview", port = 7000), "http://127.0.0.1:7000/?view=overview")
})
