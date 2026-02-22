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

## Examples

``` r
chunk_fixed(paste(rep("word", 200), collapse = " "), size = 100, overlap = 10)
#>  [1] "word word word word word word word word word word word word word word word word word word word word "
#>  [2] "word word word word word word word word word word word word word word word word word word word word "
#>  [3] "word word word word word word word word word word word word word word word word word word word word "
#>  [4] "word word word word word word word word word word word word word word word word word word word word "
#>  [5] "word word word word word word word word word word word word word word word word word word word word "
#>  [6] "word word word word word word word word word word word word word word word word word word word word "
#>  [7] "word word word word word word word word word word word word word word word word word word word word "
#>  [8] "word word word word word word word word word word word word word word word word word word word word "
#>  [9] "word word word word word word word word word word word word word word word word word word word word "
#> [10] "word word word word word word word word word word word word word word word word word word word word "
#> [11] "word word word word word word word word word word word word word word word word word word word word" 
```
