# Add documents to a retriever

Chunks documents, embeds the chunks, and adds them to the vector store.

## Usage

``` r
add_documents(ret, documents, chunk_strategy = "recursive", ...)
```

## Arguments

- ret:

  A `securecontext_retriever` object.

- documents:

  A list of `securecontext_document` objects, or a single document.

- chunk_strategy:

  Chunking strategy (see
  [`chunk_text()`](https://ian-flores.github.io/securecontext/reference/chunk_text.md)).

- ...:

  Additional arguments passed to
  [`chunk_text()`](https://ian-flores.github.io/securecontext/reference/chunk_text.md).

## Value

The retriever, invisibly.

## Examples

``` r
emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
vs <- vector_store$new(dims = emb@dims)
ret <- retriever(vs, emb)
add_documents(ret, document("The cat sat on the mat."))
vs$size()
#> [1] 1
```
