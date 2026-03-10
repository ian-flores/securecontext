test_that("chunk_text emits span when trace active", {
  skip_if_not_installed("securetrace")

  result <- securetrace::with_trace("test-chunk", {
    chunk_text("Hello world. This is a test. More text here.", strategy = "sentence")
  })

  expect_true(is.character(result))
  expect_true(length(result) > 0)
})

test_that("embed_tfidf emits span when trace active", {
  skip_if_not_installed("securetrace")

  result <- securetrace::with_trace("test-embed", {
    embed_tfidf(c("hello world", "foo bar baz"))
  })

  expect_true(S7_inherits(result, securecontext_embedder))
})

test_that("embed_texts emits span when trace active", {
  skip_if_not_installed("securetrace")

  result <- securetrace::with_trace("test-embed-texts", {
    emb <- embed_tfidf(c("hello world", "foo bar baz"))
    embed_texts(emb, c("hello world"))
  })

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 1L)
})

test_that("vector_store add and search emit spans when trace active", {
  skip_if_not_installed("securetrace")

  securetrace::with_trace("test-vector-store", {
    vs <- vector_store$new(dims = 3L)
    vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
    vs$add("id2", matrix(c(0, 1, 0), nrow = 1))
    result <- vs$search(c(1, 0, 0), k = 1)
    expect_equal(nrow(result), 1L)
    expect_equal(result$id, "id1")
  })
})

test_that("retrieve emits span when trace active", {
  skip_if_not_installed("securetrace")

  securetrace::with_trace("test-retrieve", {
    emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
    vs <- vector_store$new(dims = emb@dims)
    ret <- retriever(vs, emb)
    add_documents(ret, document("The cat sat on the mat."))
    result <- retrieve(ret, "cat", k = 1)
    expect_true(nrow(result) > 0)
  })
})

test_that("cb_build emits span when trace active", {
  skip_if_not_installed("securetrace")

  result <- securetrace::with_trace("test-cb-build", {
    cb <- context_builder(max_tokens = 100)
    cb <- cb_add(cb, "Important info", priority = 10)
    cb_build(cb)
  })

  expect_true(is.list(result))
  expect_true(nchar(result$context) > 0)
})

test_that("context_for_chat emits span when trace active", {
  skip_if_not_installed("securetrace")

  result <- securetrace::with_trace("test-context-for-chat", {
    emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
    vs <- vector_store$new(dims = emb@dims)
    ret <- retriever(vs, emb)
    add_documents(ret, document("The cat sat on the mat."))
    context_for_chat(ret, "cat", max_tokens = 100, k = 2)
  })

  expect_true(is.list(result))
  expect_true("context" %in% names(result))
})

test_that("functions work without trace", {
  result <- chunk_text("Hello world. Another sentence.", strategy = "sentence")
  expect_true(is.character(result))
  expect_true(length(result) > 0)
})

test_that("embed_tfidf works without trace", {
  result <- embed_tfidf(c("hello world", "foo bar"))
  expect_true(S7_inherits(result, securecontext_embedder))
})

test_that("cb_build works without trace", {
  cb <- context_builder(max_tokens = 100)
  cb <- cb_add(cb, "Some text", priority = 5)
  result <- cb_build(cb)
  expect_true(is.list(result))
  expect_equal(result$included, "item_1")
})
