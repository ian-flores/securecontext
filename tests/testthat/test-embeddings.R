test_that("embed_tfidf() creates a valid embedder", {
  emb <- embed_tfidf(c("the cat sat", "the dog ran", "a fish swam"))
  expect_true(S7::S7_inherits(emb, securecontext_embedder))
  expect_true(emb@dims > 0L)
})

test_that("embed_texts() returns correct dimensions", {
  corpus <- c("hello world", "foo bar baz", "hello foo")
  emb <- embed_tfidf(corpus)
  mat <- embed_texts(emb, c("hello", "foo"))
  expect_equal(nrow(mat), 2L)
  expect_equal(ncol(mat), emb@dims)
})

test_that("TF-IDF embeddings are normalized", {
  emb <- embed_tfidf(c("a b c", "d e f"))
  mat <- embed_texts(emb, c("a b"))
  norms <- sqrt(rowSums(mat^2))
  # Should be approximately 1 (or 0 if no vocab match)
  expect_true(all(norms < 1.01))
})

test_that("new_embedder() validates inputs", {
  expect_error(new_embedder("not_a_fn", 10), "must be a function")
})

test_that("embed_texts() validates embedder", {
  expect_error(embed_texts("not_an_embedder", "hi"), "must be a")
})

test_that("embed_tfidf() rejects empty corpus", {
  expect_error(embed_tfidf(character(0)), "non-empty character vector")
})
