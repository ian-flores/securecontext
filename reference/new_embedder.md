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
