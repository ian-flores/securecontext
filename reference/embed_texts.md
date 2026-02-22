# Embed texts using an embedder

Embed texts using an embedder

## Usage

``` r
embed_texts(embedder, texts)
```

## Arguments

- embedder:

  A `securecontext_embedder` object.

- texts:

  Character vector of texts to embed.

## Value

Numeric matrix with `length(texts)` rows and `embedder@dims` columns.

## Examples

``` r
emb <- embed_tfidf(c("the cat sat", "the dog ran"))
mat <- embed_texts(emb, c("cat sat", "dog ran"))
nrow(mat)
#> [1] 2
```
