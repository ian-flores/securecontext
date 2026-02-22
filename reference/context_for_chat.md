# Build context for LLM chat

Convenience function that retrieves relevant chunks and builds a
token-limited context string.

## Usage

``` r
context_for_chat(ret, query, max_tokens = 4000L, k = 10L)
```

## Arguments

- ret:

  A `securecontext_retriever` object.

- query:

  Character string query.

- max_tokens:

  Maximum tokens for the context.

- k:

  Number of chunks to retrieve.

## Value

A list with `context`, `included`, `excluded`, and `total_tokens`.

## Examples

``` r
emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
vs <- vector_store$new(dims = emb@dims)
ret <- retriever(vs, emb)
add_documents(ret, document("The cat sat on the mat."))
result <- context_for_chat(ret, "cat", max_tokens = 100, k = 2)
result$context
#> [1] "The cat sat on the mat."
```
