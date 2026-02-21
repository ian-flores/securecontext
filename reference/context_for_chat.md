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
