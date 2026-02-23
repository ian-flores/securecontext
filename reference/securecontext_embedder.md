# S7 class for securecontext embedders

S7 class for securecontext embedders

## Usage

``` r
securecontext_embedder(embed_fn = function() NULL, dims = integer(0))
```

## Arguments

- embed_fn:

  A function taking a character vector and returning a numeric matrix.

- dims:

  Integer, the dimensionality of the embedding space.

## Value

A `securecontext_embedder` S7 object.

## Examples

``` r
emb <- embed_tfidf(c("hello world", "goodbye world"))
emb@dims
#> [1] 3
```
