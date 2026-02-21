test_that("document() creates a valid document", {
  doc <- document("hello world", metadata = list(source = "test"))
  expect_true(is_document(doc))
  expect_equal(doc$text, "hello world")
  expect_equal(doc$metadata$source, "test")
  expect_true(nzchar(doc$id))
})

test_that("document() auto-generates id", {
  d1 <- document("a")
  d2 <- document("b")
  expect_false(d1$id == d2$id)
})

test_that("document() respects explicit id", {
  doc <- document("hi", id = "my_id")
  expect_equal(doc$id, "my_id")
})

test_that("document() rejects non-string text", {
  expect_error(document(123), "must be a single character string")
  expect_error(document(c("a", "b")), "must be a single character string")
})

test_that("is_document() works", {
  expect_true(is_document(document("x")))
  expect_false(is_document("x"))
  expect_false(is_document(list(text = "x")))
})

test_that("print.securecontext_document() works", {
  doc <- document("hello world", metadata = list(a = 1))
  out <- capture.output(print(doc))
  expect_true(any(grepl("securecontext_document", out)))
  expect_true(any(grepl("hello world", out)))
})
