# Reset a context builder

Removes all added content.

## Usage

``` r
context_reset(builder)

cb_reset(...)
```

## Arguments

- builder:

  A `securecontext_context_builder`.

- ...:

  Arguments passed to `context_reset()`.

## Value

Reset builder.

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb <- context_add(cb, "some text")
cb <- context_reset(cb)
length(cb@items)
#> [1] 0
```
