# Create a TF-IDF embedder

Builds a TF-IDF vocabulary from a corpus and returns an embedder that
can embed new texts into that vocabulary space. No external API
required.

## Usage

``` r
embed_tfidf(corpus)
```

## Arguments

- corpus:

  Character vector of documents to build vocabulary from.

## Value

A `securecontext_embedder` object.

## Examples

``` r
emb <- embed_tfidf(c("the cat sat", "the dog ran"))
```
