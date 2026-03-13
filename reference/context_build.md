# Build the context string

Assembles context by including highest-priority items first until the
token limit is reached.

## Usage

``` r
context_build(builder)

cb_build(...)
```

## Arguments

- builder:

  A `securecontext_context_builder`.

- ...:

  Arguments passed to `context_build()`.

## Value

A list with elements `context` (assembled string), `included` (labels of
included items), `excluded` (labels of excluded items), and
`total_tokens` (token count of assembled context).

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb <- context_add(cb, "Important info", priority = 10)
result <- context_build(cb)
result$context
#> [1] "Important info"
```
