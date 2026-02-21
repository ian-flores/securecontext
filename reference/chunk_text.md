# Chunk text into smaller pieces

Splits text using the specified strategy.

## Usage

``` r
chunk_text(
  text,
  strategy = c("fixed", "sentence", "paragraph", "recursive"),
  ...
)
```

## Arguments

- text:

  Character string to chunk.

- strategy:

  Chunking strategy: `"fixed"`, `"sentence"`, `"paragraph"`, or
  `"recursive"`.

- ...:

  Additional arguments passed to the strategy function.

## Value

Character vector of chunks.

## Examples

``` r
chunks <- chunk_text("Hello world. How are you?", strategy = "sentence")
```
