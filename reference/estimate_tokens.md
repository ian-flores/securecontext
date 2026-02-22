# Estimate token count

Alias for
[`count_tokens()`](https://ian-flores.github.io/securecontext/reference/count_tokens.md)
with the default `"words"` method.

## Usage

``` r
estimate_tokens(text)
```

## Arguments

- text:

  Character string (or vector) to count tokens for.

## Value

Numeric token count estimate.

## Examples

``` r
estimate_tokens("Hello world, this is a test.")
#> [1] 8
```
