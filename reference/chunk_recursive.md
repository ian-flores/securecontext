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
