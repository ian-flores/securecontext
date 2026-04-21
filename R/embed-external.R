#' Wrap an arbitrary embedding function as a securecontext embedder
#'
#' Generic plug-in point for external embedders. `fn` must be a function
#' that takes a character vector and returns a numeric matrix with one
#' row per input text and `dims` columns. The function is called inside
#' [embed_texts()] and therefore inherits its tracing span if a trace is
#' active.
#'
#' Unlike [embed_tfidf()], no local corpus is needed; you are responsible
#' for ensuring the underlying model produces the dimensionality you
#' declare.
#'
#' @param fn A function `function(texts) -> matrix` where
#'   `ncol(result) == dims` and `nrow(result) == length(texts)`.
#' @param dims Integer, the dimensionality of the embedding space.
#' @param name Character scalar, an informational label used in
#'   diagnostic output. Defaults to `"custom"`.
#' @return A [securecontext_embedder] object.
#' @export
#' @examples
#' fake <- function(texts) matrix(runif(length(texts) * 8L), ncol = 8L)
#' emb <- embed_custom(fake, dims = 8L, name = "fake")
#' embed_texts(emb, c("hello", "world"))
embed_custom <- function(fn, dims, name = "custom") {
  if (!is.function(fn)) {
    cli_abort("{.arg fn} must be a function.")
  }
  if (!is.character(name) || length(name) != 1L) {
    cli_abort("{.arg name} must be a single character string.")
  }
  dims <- as.integer(dims)

  wrapped <- function(texts) {
    result <- fn(texts)
    if (!is.matrix(result) || !is.numeric(result)) {
      cli_abort(
        "Custom embedder {.val {name}} must return a numeric matrix."
      )
    }
    if (ncol(result) != dims) {
      cli_abort(
        "Custom embedder {.val {name}} returned matrix with
         {ncol(result)} cols, expected {dims}."
      )
    }
    if (nrow(result) != length(texts)) {
      cli_abort(
        "Custom embedder {.val {name}} returned {nrow(result)} rows for
         {length(texts)} inputs."
      )
    }
    result
  }

  embedder(wrapped, dims)
}

#' OpenAI embeddings via the REST API
#'
#' Convenience wrapper that posts to `POST /v1/embeddings` on the OpenAI
#' API. Requires `httr2` (Suggests). Batches requests at `batch_size`
#' per call. This does NOT wrap ellmer; ellmer does not currently expose
#' an embedding API (chat-only). Use [embed_custom()] if you prefer to
#' route through a different SDK.
#'
#' Privacy note: unlike [embed_tfidf()], this sends text to OpenAI. Only
#' enable it when that is acceptable for your data classification.
#'
#' @param model Model identifier. Defaults to
#'   `"text-embedding-3-small"` (1536 dims, \$0.02/1M tokens as of
#'   late 2025).
#' @param dims Expected dimensionality. Defaults to `1536L` which
#'   matches `text-embedding-3-small`. Pass the correct value for other
#'   models (e.g. `3072L` for `text-embedding-3-large`).
#' @param api_key OpenAI API key. Defaults to `OPENAI_API_KEY` env var.
#' @param base_url API base URL (override for Azure OpenAI or proxies).
#' @param batch_size Number of texts per POST.
#' @param timeout Per-request timeout in seconds.
#' @return A [securecontext_embedder] object.
#' @export
#' @examples
#' \dontrun{
#' emb <- embed_openai()
#' embed_texts(emb, c("hello world"))
#' }
embed_openai <- function(model = "text-embedding-3-small",
                         dims = 1536L,
                         api_key = Sys.getenv("OPENAI_API_KEY"),
                         base_url = "https://api.openai.com/v1",
                         batch_size = 64L,
                         timeout = 30) {
  if (!requireNamespace("httr2", quietly = TRUE)) {
    cli_abort(
      "{.pkg httr2} is required for {.fn embed_openai}. Install it with
       {.code install.packages('httr2')}."
    )
  }
  if (!nzchar(api_key)) {
    cli_abort(
      "{.arg api_key} is empty. Set the {.envvar OPENAI_API_KEY}
       environment variable or pass {.arg api_key} explicitly."
    )
  }
  dims <- as.integer(dims)
  batch_size <- as.integer(batch_size)

  fn <- function(texts) {
    n <- length(texts)
    out <- matrix(0, nrow = n, ncol = dims)
    starts <- seq.int(1L, n, by = batch_size)
    for (start in starts) {
      end <- min(start + batch_size - 1L, n)
      body <- list(model = model, input = as.list(texts[start:end]))
      resp <- httr2::request(base_url) |>
        httr2::req_url_path_append("embeddings") |>
        httr2::req_auth_bearer_token(api_key) |>
        httr2::req_timeout(timeout) |>
        httr2::req_body_json(body) |>
        httr2::req_perform()
      parsed <- httr2::resp_body_json(resp, simplifyVector = FALSE)
      vectors <- lapply(parsed$data, function(row) as.numeric(row$embedding))
      if (length(vectors) != (end - start + 1L)) {
        cli_abort("OpenAI returned {length(vectors)} vectors for a batch of
                   {end - start + 1L}.")
      }
      for (i in seq_along(vectors)) {
        if (length(vectors[[i]]) != dims) {
          cli_abort(
            "OpenAI returned vector of length {length(vectors[[i]])} for
             model {.val {model}}; expected {.arg dims} = {dims}."
          )
        }
        out[start + i - 1L, ] <- vectors[[i]]
      }
    }
    out
  }

  embed_custom(fn, dims = dims, name = paste0("openai:", model))
}
