test_that("vector_store basic operations", {
  vs <- vector_store$new(dims = 3L)
  expect_equal(vs$size(), 0L)

  embs <- matrix(c(1, 0, 0, 0, 1, 0), nrow = 2, byrow = TRUE)
  vs$add(c("a", "b"), embs)
  expect_equal(vs$size(), 2L)

  results <- vs$search(c(1, 0, 0), k = 1L)
  expect_equal(results$id[1], "a")
  expect_equal(results$score[1], 1, tolerance = 1e-6)
})

test_that("vector_store$remove()", {
  vs <- vector_store$new(dims = 2L)
  embs <- matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE)
  vs$add(c("x", "y"), embs)
  vs$remove("x")
  expect_equal(vs$size(), 1L)

  results <- vs$search(c(1, 0), k = 2L)
  expect_equal(nrow(results), 1L)
})

test_that("vector_store save/load roundtrip", {
  vs <- vector_store$new(dims = 2L)
  embs <- matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE)
  vs$add(c("a", "b"), embs, metadata = list(list(x = 1), list(x = 2)))

  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  vs$save(path)

  vs2 <- vector_store$new(dims = 2L)
  vs2$load(path)
  expect_equal(vs2$size(), 2L)

  results <- vs2$search(c(1, 0), k = 1L)
  expect_equal(results$id[1], "a")
})

test_that("vector_store handles duplicate ids", {
  vs <- vector_store$new(dims = 2L)
  embs1 <- matrix(c(1, 0), nrow = 1)
  embs2 <- matrix(c(0, 1), nrow = 1)
  vs$add("a", embs1)
  vs$add("a", embs2)
  expect_equal(vs$size(), 1L)
})

test_that("vector_store$search() on empty store", {
  vs <- vector_store$new(dims = 2L)
  results <- vs$search(c(1, 0))
  expect_equal(nrow(results), 0L)
})

test_that("vector_store encrypted save/load round-trip", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  vs <- vector_store$new(dims = 2L, encryption_key = key)
  embs <- matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE)
  vs$add(c("a", "b"), embs, metadata = list(list(x = 1), list(x = 2)))

  path <- tempfile(fileext = ".enc")
  on.exit(unlink(path), add = TRUE)
  vs$save(path)

  # Encrypted file should not be readable as RDS
  expect_error(readRDS(path))

  vs2 <- vector_store$new(dims = 2L, encryption_key = key)
  vs2$load(path)
  expect_equal(vs2$size(), 2L)
  results <- vs2$search(c(1, 0), k = 1L)
  expect_equal(results$id[1], "a")
})

test_that("vector_store load validates deserialized data", {
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(list(bad = "data"), path)

  vs <- vector_store$new(dims = 2L)
  expect_error(vs$load(path), "missing required fields")
})

test_that("vector_store load rejects non-list data", {
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS("not a list", path)

  vs <- vector_store$new(dims = 2L)
  expect_error(vs$load(path), "expected a list")
})

test_that("vector_store load validates field types", {
  vs <- vector_store$new(dims = 2L)

  # Wrong dims type
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(list(dims = "two", ids = character(), embeddings = matrix(0, 0, 2), metadata = list()), path)
  expect_error(vs$load(path), "dims")

  # Wrong ids type
  path2 <- tempfile(fileext = ".rds")
  on.exit(unlink(path2), add = TRUE)
  saveRDS(list(dims = 2L, ids = 123, embeddings = matrix(0, 0, 2), metadata = list()), path2)
  expect_error(vs$load(path2), "ids")

  # Wrong embeddings type
  path3 <- tempfile(fileext = ".rds")
  on.exit(unlink(path3), add = TRUE)
  saveRDS(list(dims = 2L, ids = character(), embeddings = "not a matrix", metadata = list()), path3)
  expect_error(vs$load(path3), "embeddings")

  # Wrong metadata type
  path4 <- tempfile(fileext = ".rds")
  on.exit(unlink(path4), add = TRUE)
  saveRDS(list(dims = 2L, ids = character(), embeddings = matrix(0, 0, 2), metadata = "not a list"), path4)
  expect_error(vs$load(path4), "metadata")
})
