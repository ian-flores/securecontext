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

## Examples

``` r
emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
vs <- vector_store$new(dims = emb@dims)
ret <- retriever(vs, emb)
add_documents(ret, document("The cat sat on the mat."))
retrieve(ret, "cat", k = 1)
#>                         id     score
#> 1 doc_1b97590c62b1_chunk_1 0.5773503
```
