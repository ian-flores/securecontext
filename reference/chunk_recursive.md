# Recursive text chunking

Recursively splits text using a hierarchy of separators, similar to
LangChain's recursive text splitter.

## Usage

``` r
chunk_recursive(
  text,
  max_size = 500L,
  separators = c("\n\n", "\n", ". ", " ")
)
```

## Arguments

- text:

  Character string to chunk.

- max_size:

  Maximum chunk size in characters.

- separators:

  Character vector of separators to try in order.

## Value

Character vector of chunks.

## Examples

``` r
long_text <- paste(rep("This is a sentence.", 20), collapse = " ")
chunk_recursive(long_text, max_size = 80)
#>  [1] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#>  [4] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#>  [7] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#> [10] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#> [13] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#> [16] "This is a sentence"  "This is a sentence"  "This is a sentence" 
#> [19] "This is a sentence"  "This is a sentence."
```
