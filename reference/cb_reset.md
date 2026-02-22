# Reset a context builder

Removes all added content.

## Usage

``` r
cb_reset(builder)
```

## Arguments

- builder:

  A `securecontext_context_builder`.

## Value

Reset builder.

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb <- cb_add(cb, "some text")
cb <- cb_reset(cb)
length(cb@items)
#> [1] 0
```
