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

Numeric matrix with `length(texts)` rows and `embedder$dims` columns.
