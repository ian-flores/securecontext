# Create a context builder

Token-aware context assembly with priority-based inclusion.

## Usage

``` r
context_builder(max_tokens = 4000L)
```

## Arguments

- max_tokens:

  Maximum number of tokens for the assembled context.

## Value

A `securecontext_context_builder` object.

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb <- cb_add(cb, "Important info", priority = 10)
cb <- cb_add(cb, "Less important", priority = 1)
result <- cb_build(cb)
```
