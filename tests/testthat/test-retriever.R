test_that("retriever end-to-end", {
  corpus <- c(
    "The cat sat on the mat.",
    "Dogs love to play fetch.",
    "Fish swim in the ocean."
  )
  emb <- embed_tfidf(corpus)
  vs <- vector_store$new(dims = emb$dims)
  ret <- retriever(vs, emb)

  docs <- lapply(corpus, function(txt) document(txt))
  add_documents(ret, docs, chunk_strategy = "sentence")

  expect_true(vs$size() > 0L)

  results <- retrieve(ret, "cat mat", k = 2L)
  expect_true(nrow(results) > 0L)
  expect_true(is.numeric(results$score))
})

test_that("retriever() validates inputs", {
  expect_error(retriever("not_store", "not_emb"), "must be a")
})

test_that("retrieve() validates input", {
  expect_error(retrieve("not_a_retriever", "query"), "must be a")
})

test_that("add_documents() accepts single document", {
  emb <- embed_tfidf(c("hello world", "foo bar"))
  vs <- vector_store$new(dims = emb$dims)
  ret <- retriever(vs, emb)

  doc <- document("hello world test doc")
  add_documents(ret, doc)
  expect_true(vs$size() > 0L)
})
