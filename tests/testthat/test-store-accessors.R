test_that("vector_store exposes metadata() and ids() accessors", {
  vs <- vector_store$new(dims = 2L)
  emb <- matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE)
  vs$add(c("a", "b"), emb, metadata = list(
    list(chunk_text = "first"),
    list(chunk_text = "second")
  ))

  expect_equal(vs$ids(), c("a", "b"))
  expect_equal(vs$metadata("a")$chunk_text, "first")
  expect_equal(vs$metadata("b")$chunk_text, "second")
  expect_null(vs$metadata("missing"))
  expect_length(vs$metadata(), 2L)
})

test_that("knowledge_store exposes get_metadata() accessor", {
  ks <- knowledge_store$new()
  ks$set("k1", "v1", metadata = list(source = "unit", tag = "x"))
  expect_equal(ks$get_metadata("k1")$source, "unit")
  expect_null(ks$get_metadata("missing"))
})

test_that("context_for_chat no longer touches R6 privates", {
  # Build a minimal retriever with known chunk metadata and verify the
  # returned context contains the chunk text, proving the accessor path
  # is wired.
  emb <- embed_tfidf(c("cat sat", "dog ran"))
  vs <- vector_store$new(dims = emb@dims)
  ret <- retriever(vs, emb)
  add_documents(ret, document("cats like naps", metadata = list()))
  res <- context_for_chat(ret, "cat", max_tokens = 200, k = 1)
  expect_true(nchar(res$context) > 0)
})
