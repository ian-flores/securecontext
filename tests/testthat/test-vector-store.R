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
