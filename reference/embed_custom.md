# Wrap an arbitrary embedding function as a securecontext embedder

Generic plug-in point for external embedders. `fn` must be a function
that takes a character vector and returns a numeric matrix with one row
per input text and `dims` columns. The function is called inside
[`embed_texts()`](https://ian-flores.github.io/securecontext/reference/embed_texts.md)
and therefore inherits its tracing span if a trace is active.

## Usage

``` r
embed_custom(fn, dims, name = "custom")
```

## Arguments

- fn:

  A function `function(texts) -> matrix` where `ncol(result) == dims`
  and `nrow(result) == length(texts)`.

- dims:

  Integer, the dimensionality of the embedding space.

- name:

  Character scalar, an informational label used in diagnostic output.
  Defaults to `"custom"`.

## Value

A
[securecontext_embedder](https://ian-flores.github.io/securecontext/reference/securecontext_embedder.md)
object.

## Details

Unlike
[`embed_tfidf()`](https://ian-flores.github.io/securecontext/reference/embed_tfidf.md),
no local corpus is needed; you are responsible for ensuring the
underlying model produces the dimensionality you declare.

## Examples

``` r
fake <- function(texts) matrix(runif(length(texts) * 8L), ncol = 8L)
emb <- embed_custom(fake, dims = 8L, name = "fake")
embed_texts(emb, c("hello", "world"))
#>           [,1]       [,2]      [,3]       [,4]      [,5]      [,6]      [,7]
#> [1,] 0.9805397 0.05144628 0.6958239 0.03123033 0.3008308 0.4790245 0.7064338
#> [2,] 0.7415215 0.53021246 0.6885560 0.22556253 0.6364656 0.4321713 0.9485766
#>           [,8]
#> [1,] 0.1803388
#> [2,] 0.2168999
```
