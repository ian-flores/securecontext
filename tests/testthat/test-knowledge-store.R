test_that("knowledge_store basic CRUD", {
  ks <- knowledge_store$new()
  ks$set("name", "Alice")
  expect_equal(ks$get("name"), "Alice")
  expect_equal(ks$size(), 1L)

  ks$set("name", "Bob")
  expect_equal(ks$get("name"), "Bob")
  expect_equal(ks$size(), 1L)

  ks$delete("name")
  expect_null(ks$get("name"))
  expect_equal(ks$size(), 0L)
})

test_that("knowledge_store$get() default", {
  ks <- knowledge_store$new()
  expect_equal(ks$get("missing", default = 42), 42)
})

test_that("knowledge_store$search()", {
  ks <- knowledge_store$new()
  ks$set("user.name", "Alice")
  ks$set("user.age", 30)
  ks$set("config.theme", "dark")
  expect_equal(sort(ks$search("^user")), sort(c("user.name", "user.age")))
})

test_that("knowledge_store$list()", {
  ks <- knowledge_store$new()
  ks$set("a", 1)
  ks$set("b", 2)
  ks$set("c", 3)
  expect_equal(length(ks$list()), 3L)
  expect_equal(length(ks$list(n = 2)), 2L)
})

test_that("knowledge_store JSONL persistence", {
  path <- tempfile(fileext = ".jsonl")
  on.exit(unlink(path), add = TRUE)

  ks <- knowledge_store$new(path = path)
  ks$set("key1", "value1")
  ks$set("key2", list(a = 1, b = 2))
  expect_true(file.exists(path))

  ks2 <- knowledge_store$new(path = path)
  expect_equal(ks2$get("key1"), "value1")
  expect_equal(ks2$get("key2")$a, 1)
  expect_equal(ks2$size(), 2L)
})

test_that("knowledge_store$set() validates key", {
  ks <- knowledge_store$new()
  expect_error(ks$set(123, "value"), "must be a single character string")
})

test_that("knowledge_store encrypted save/load round-trip", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  path <- tempfile(fileext = ".enc")
  on.exit(unlink(path), add = TRUE)

  ks <- knowledge_store$new(path = path, encryption_key = key)
  ks$set("key1", "value1")
  ks$set("key2", list(a = 1, b = 2))
  expect_true(file.exists(path))

  # Encrypted file should not be readable as plain JSONL
  raw_content <- readBin(path, "raw", file.info(path)$size)
  parsed <- tryCatch(
    jsonlite::fromJSON(rawToChar(raw_content)),
    error = function(e) NULL
  )
  expect_null(parsed)

  ks2 <- knowledge_store$new(path = path, encryption_key = key)
  expect_equal(ks2$get("key1"), "value1")
  expect_equal(ks2$get("key2")$a, 1)
  expect_equal(ks2$size(), 2L)
})

test_that("knowledge_store search() handles invalid regex safely", {
  ks <- knowledge_store$new()
  ks$set("user.name", "Alice")
  ks$set("user.age", 30)

  expect_warning(
    result <- ks$search("[invalid"),
    "Invalid regex"
  )
  expect_equal(result, character())
})

test_that("knowledge_store search() still works with valid regex", {
  ks <- knowledge_store$new()
  ks$set("user.name", "Alice")
  ks$set("config.theme", "dark")

  result <- ks$search("^user")
  expect_equal(result, "user.name")
})
