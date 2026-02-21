# Retrieve relevant chunks

Embeds the query, searches the vector store, and returns results.

## Usage

``` r
retrieve(ret, query, k = 5L)
```

## Arguments

- ret:

  A `securecontext_retriever` object.

- query:

  Character string query.

- k:

  Number of results.

## Value

Data frame with columns `id`, `score`.
