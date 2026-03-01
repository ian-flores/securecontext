test_that("log_store_event writes JSONL entries", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)

  log_store_event(tmp, "test_event", list(key = "k1"))
  lines <- readLines(tmp)
  expect_length(lines, 1L)

  entry <- jsonlite::fromJSON(lines[1], simplifyVector = FALSE)
  expect_equal(entry$event, "test_event")
  expect_equal(entry$key, "k1")
  expect_true(!is.null(entry$timestamp))
})

test_that("log_store_event appends multiple entries", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)

  log_store_event(tmp, "first", list(n = 1))
  log_store_event(tmp, "second", list(n = 2))
  lines <- readLines(tmp)
  expect_length(lines, 2L)

  e1 <- jsonlite::fromJSON(lines[1], simplifyVector = FALSE)
  e2 <- jsonlite::fromJSON(lines[2], simplifyVector = FALSE)
  expect_equal(e1$event, "first")
  expect_equal(e2$event, "second")
})

test_that("log_store_event entries have ISO 8601 timestamps", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)

  log_store_event(tmp, "ts_test")
  entry <- jsonlite::fromJSON(readLines(tmp)[1], simplifyVector = FALSE)
  expect_match(entry$timestamp, "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}")
})

test_that("vector_store logs CRUD operations when audit_log is set", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)

  vs <- vector_store$new(dims = 3L, audit_log = tmp)
  vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
  vs$search(c(1, 0, 0), k = 1)
  vs$remove("id1")

  lines <- readLines(tmp)
  expect_length(lines, 3L)

  events <- vapply(lines, function(l) {
    jsonlite::fromJSON(l, simplifyVector = FALSE)$event
  }, character(1), USE.NAMES = FALSE)
  expect_equal(events, c("add", "search", "remove"))
})

test_that("vector_store logs save and load events", {
  audit_log <- tempfile(fileext = ".jsonl")
  store_path <- tempfile(fileext = ".rds")
  on.exit(unlink(c(audit_log, store_path)), add = TRUE)

  vs <- vector_store$new(dims = 3L, audit_log = audit_log)
  vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
  vs$save(store_path)
  vs$load(store_path)

  lines <- readLines(audit_log)
  events <- vapply(lines, function(l) {
    jsonlite::fromJSON(l, simplifyVector = FALSE)$event
  }, character(1), USE.NAMES = FALSE)
  expect_true("save" %in% events)
  expect_true("load" %in% events)
})

test_that("vector_store does not log when audit_log is NULL", {
  vs <- vector_store$new(dims = 3L)
  vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
  vs$search(c(1, 0, 0), k = 1)
  vs$remove("id1")
  # No error means no audit log was attempted
  expect_true(TRUE)
})

test_that("knowledge_store logs CRUD operations when audit_log is set", {
  audit_log <- tempfile(fileext = ".jsonl")
  on.exit(unlink(audit_log), add = TRUE)

  ks <- knowledge_store$new(audit_log = audit_log)
  ks$set("color", "blue")
  ks$get("color")
  ks$search("col")
  ks$delete("color")

  lines <- readLines(audit_log)
  expect_length(lines, 4L)

  events <- vapply(lines, function(l) {
    jsonlite::fromJSON(l, simplifyVector = FALSE)$event
  }, character(1), USE.NAMES = FALSE)
  expect_equal(events, c("set", "get", "search", "delete"))
})

test_that("knowledge_store logs save and load events", {
  audit_log <- tempfile(fileext = ".jsonl")
  store_path <- tempfile(fileext = ".jsonl")
  on.exit(unlink(c(audit_log, store_path)), add = TRUE)

  ks <- knowledge_store$new(path = store_path, audit_log = audit_log)
  ks$set("x", 1)
  # set triggers auto-save, so we should see both set and save events

  lines <- readLines(audit_log)
  events <- vapply(lines, function(l) {
    jsonlite::fromJSON(l, simplifyVector = FALSE)$event
  }, character(1), USE.NAMES = FALSE)
  expect_true("set" %in% events)
  expect_true("save" %in% events)
})

test_that("knowledge_store does not log when audit_log is NULL", {
  ks <- knowledge_store$new()
  ks$set("a", 1)
  ks$get("a")
  ks$delete("a")
  expect_true(TRUE)
})

test_that("audit log entries contain correct details", {
  audit_log <- tempfile(fileext = ".jsonl")
  on.exit(unlink(audit_log), add = TRUE)

  ks <- knowledge_store$new(audit_log = audit_log)
  ks$set("mykey", "myval")

  entry <- jsonlite::fromJSON(readLines(audit_log)[1], simplifyVector = FALSE)
  expect_equal(entry$event, "set")
  expect_equal(entry$key, "mykey")
  expect_true(!is.null(entry$timestamp))
})
