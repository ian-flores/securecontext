# S7 class for securecontext retrievers

S7 class for securecontext retrievers

## Usage

``` r
securecontext_retriever(store = NULL, embedder = NULL)
```

## Arguments

- store:

  A
  [vector_store](https://ian-flores.github.io/securecontext/reference/vector_store.md)
  object.

- embedder:

  A `securecontext_embedder` object.

## Value

A `securecontext_retriever` S7 object.

## Examples

``` r
emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
vs <- vector_store$new(dims = emb@dims)
ret <- retriever(vs, emb)
ret@embedder
#> <securecontext::securecontext_embedder>
#>  @ embed_fn: function (texts)  
#>  @ dims    : int 8
```
