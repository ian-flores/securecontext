# Sentence-based text chunking

Splits text on sentence boundaries (period followed by space or
newline).

## Usage

``` r
chunk_sentence(text)
```

## Arguments

- text:

  Character string to chunk.

## Value

Character vector of sentence chunks.

## Examples

``` r
chunk_sentence("First sentence. Second sentence. Third one.")
#> [1] "First sentence."  "Second sentence." "Third one."      
```
