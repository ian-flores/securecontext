# OpenAI embeddings via the REST API

Convenience wrapper that posts to `POST /v1/embeddings` on the OpenAI
API. Requires `httr2` (Suggests). Batches requests at `batch_size` per
call. This does NOT wrap ellmer; ellmer does not currently expose an
embedding API (chat-only). Use
[`embed_custom()`](https://ian-flores.github.io/securecontext/reference/embed_custom.md)
if you prefer to route through a different SDK.

## Usage

``` r
embed_openai(
  model = "text-embedding-3-small",
  dims = 1536L,
  api_key = Sys.getenv("OPENAI_API_KEY"),
  base_url = "https://api.openai.com/v1",
  batch_size = 64L,
  timeout = 30
)
```

## Arguments

- model:

  Model identifier. Defaults to `"text-embedding-3-small"` (1536 dims,
  \\0.02/1M tokens as of late 2025).

- dims:

  Expected dimensionality. Defaults to `1536L` which matches
  `text-embedding-3-small`. Pass the correct value for other models
  (e.g. `3072L` for `text-embedding-3-large`).

- api_key:

  OpenAI API key. Defaults to `OPENAI_API_KEY` env var.

- base_url:

  API base URL (override for Azure OpenAI or proxies).

- batch_size:

  Number of texts per POST.

- timeout:

  Per-request timeout in seconds.

## Value

A
[securecontext_embedder](https://ian-flores.github.io/securecontext/reference/securecontext_embedder.md)
object.

## Details

Privacy note: unlike
[`embed_tfidf()`](https://ian-flores.github.io/securecontext/reference/embed_tfidf.md),
this sends text to OpenAI. Only enable it when that is acceptable for
your data classification.

## Examples

``` r
if (FALSE) { # \dontrun{
emb <- embed_openai()
embed_texts(emb, c("hello world"))
} # }
```
