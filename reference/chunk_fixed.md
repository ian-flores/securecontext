# Fixed-size text chunking

Splits text into chunks of approximately `size` characters with optional
overlap.

## Usage

``` r
chunk_fixed(text, size = 500L, overlap = 50L)
```

## Arguments

- text:

  Character string to chunk.

- size:

  Target chunk size in characters.

- overlap:

  Number of overlap characters between consecutive chunks.

## Value

Character vector of chunks.
