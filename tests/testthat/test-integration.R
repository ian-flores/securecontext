test_that("as_orchestr_memory() wraps knowledge store", {
  ks <- knowledge_store$new()
  mem <- as_orchestr_memory(ks)

  expect_true(is.function(mem$get))
  expect_true(is.function(mem$set))

  mem$set("key", "value")
  expect_equal(mem$get("key"), "value")
  expect_null(mem$get("missing"))
  expect_equal(mem$get("missing", default = "fallback"), "fallback")
})

test_that("as_orchestr_memory() validates input", {
  expect_error(as_orchestr_memory("not_ks"), "must be a")
})

test_that("context_for_chat() works end to end", {
  corpus <- c("R is a language for statistics.", "Python is popular for ML.")
  emb <- embed_tfidf(corpus)
  vs <- vector_store$new(dims = emb$dims)
  ret <- retriever(vs, emb)

  docs <- lapply(corpus, function(txt) document(txt))
  add_documents(ret, docs, chunk_strategy = "sentence")

  result <- context_for_chat(ret, "statistics language", max_tokens = 4000L)
  expect_true(is.list(result))
  expect_true(nzchar(result$context))
})

test_that("context_for_chat() validates retriever", {
  expect_error(context_for_chat("not_ret", "query"), "must be a")
})
