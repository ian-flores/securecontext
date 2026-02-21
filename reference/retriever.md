# Create a retriever

Wraps a
[vector_store](https://ian-flores.github.io/securecontext/reference/vector_store.md)
and an embedder for semantic retrieval.

## Usage

``` r
retriever(store, embedder)
```

## Arguments

- store:

  A
  [vector_store](https://ian-flores.github.io/securecontext/reference/vector_store.md)
  object.

- embedder:

  A `securecontext_embedder` object.

## Value

A `securecontext_retriever` object.
