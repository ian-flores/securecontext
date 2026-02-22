# Create an embedder

Constructs an embedder object from a function and dimensionality.

## Usage

``` r
new_embedder(embed_fn, dims)
```

## Arguments

- embed_fn:

  A function taking a character vector and returning a numeric matrix
  with one row per text and `dims` columns.

- dims:

  Integer, the dimensionality of the embedding space.

## Value

A `securecontext_embedder` object.

## Examples

``` r
# Create a simple random embedder
random_embed <- function(texts) matrix(runif(length(texts) * 3), ncol = 3)
emb <- new_embedder(random_embed, dims = 3L)
emb@dims
#> [1] 3
```
