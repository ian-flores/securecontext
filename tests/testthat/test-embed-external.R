test_that("embed_custom wraps a conforming function", {
  fn <- function(texts) matrix(seq_len(length(texts) * 4), ncol = 4)
  emb <- embed_custom(fn, dims = 4L, name = "stub")
  expect_true(S7::S7_inherits(emb, securecontext_embedder))
  expect_equal(emb@dims, 4L)
  m <- embed_texts(emb, c("a", "b", "c"))
  expect_equal(dim(m), c(3, 4))
})

test_that("embed_custom validates return shape", {
  wrong_cols <- function(texts) matrix(0, nrow = length(texts), ncol = 3)
  emb <- embed_custom(wrong_cols, dims = 4L)
  expect_error(embed_texts(emb, c("x")), "expected 4")

  wrong_rows <- function(texts) matrix(0, nrow = length(texts) + 1, ncol = 4)
  emb2 <- embed_custom(wrong_rows, dims = 4L)
  expect_error(embed_texts(emb2, c("x")), "rows for")

  wrong_type <- function(texts) as.character(seq_along(texts))
  emb3 <- embed_custom(wrong_type, dims = 1L)
  expect_error(embed_texts(emb3, c("x")), "numeric matrix")
})

test_that("embed_openai errors without API key", {
  withr::with_envvar(c(OPENAI_API_KEY = ""), {
    expect_error(embed_openai(api_key = ""), "api_key")
  })
})

test_that("embed_openai round-trips against a fake server", {
  skip_if_not_installed("httr2")
  skip_on_cran()

  # Return a fixed 4-dim vector regardless of the request; we don't
  # introspect the request body here because httr2's internal body
  # representation has shifted between versions and isn't a stable
  # public surface.  The important thing is that embed_openai posts
  # input, parses the response, and reshapes into a matrix.
  fake_app <- function(req) {
    data_list <- lapply(seq_len(2L), function(i) {
      list(embedding = as.list(rep(0.5, 4L)), index = i - 1L)
    })
    httr2::response(
      status_code = 200L,
      body = charToRaw(jsonlite::toJSON(
        list(data = data_list, model = "text-embedding-3-small"),
        auto_unbox = TRUE
      )),
      headers = list(`Content-Type` = "application/json")
    )
  }

  emb <- embed_openai(
    model = "text-embedding-3-small",
    dims = 4L,
    api_key = "sk-test-fake",
    base_url = "https://fake.example/v1",
    batch_size = 2L
  )

  # batch_size = 2 means 2 batches for 3 inputs; fake_app returns 2
  # rows per call, so the second batch gets 2 but only 1 is used.
  # Skip the second batch to keep the test focused.
  httr2::with_mocked_responses(fake_app, {
    out <- embed_texts(emb, c("alpha", "beta"))
  })
  expect_equal(dim(out), c(2, 4))
  expect_equal(out[1, ], rep(0.5, 4))
})
