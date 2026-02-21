# Build the context string

Assembles context by including highest-priority items first until the
token limit is reached.

## Usage

``` r
cb_build(builder)
```

## Arguments

- builder:

  A `securecontext_context_builder`.

## Value

A list with elements `context` (assembled string), `included` (labels of
included items), `excluded` (labels of excluded items), and
`total_tokens` (token count of assembled context).
