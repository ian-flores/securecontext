# S7 class for securecontext context builders

S7 class for securecontext context builders

## Usage

``` r
securecontext_context_builder(max_tokens = integer(0), items = list())
```

## Arguments

- max_tokens:

  Integer, maximum number of tokens.

- items:

  List of content items with priority.

## Value

A `securecontext_context_builder` S7 object.

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb@max_tokens
#> [1] 100
```
