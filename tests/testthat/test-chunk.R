test_that("chunk_fixed() splits text", {
  text <- paste(rep("abcde", 20), collapse = " ")
  chunks <- chunk_fixed(text, size = 30, overlap = 5)
  expect_true(length(chunks) > 1L)
  expect_true(all(nchar(chunks) <= 30L))
})
test_that("chunk_fixed() returns whole text if small enough", {
  expect_equal(chunk_fixed("short", size = 100), "short")
})

test_that("chunk_fixed() rejects overlap >= size", {
  expect_error(chunk_fixed("x", size = 10, overlap = 10), "must be less than")
})

test_that("chunk_sentence() splits on sentences", {
  text <- "First sentence. Second sentence. Third."

chunks <- chunk_sentence(text)
  expect_equal(length(chunks), 3L)
  expect_equal(chunks[1], "First sentence.")
})

test_that("chunk_paragraph() splits on double newlines", {
  text <- "Para one.\n\nPara two.\n\nPara three."
  chunks <- chunk_paragraph(text)
  expect_equal(length(chunks), 3L)
})

test_that("chunk_recursive() handles nested splitting", {
  text <- paste(rep("word", 200), collapse = " ")
  chunks <- chunk_recursive(text, max_size = 100)
  expect_true(all(nchar(chunks) <= 100L))
})

test_that("chunk_text() dispatches correctly", {
  text <- "A. B. C."
  expect_equal(
    chunk_text(text, strategy = "sentence"),
    chunk_sentence(text)
  )
})

test_that("chunk_text() rejects non-string", {
  expect_error(chunk_text(123), "must be a single character string")
})

test_that("empty text returns empty vector", {
  expect_equal(chunk_fixed("", size = 10), character(0))
  expect_equal(chunk_sentence(""), character(0))
  expect_equal(chunk_paragraph(""), character(0))
  expect_equal(chunk_recursive("", max_size = 10), character(0))
})
