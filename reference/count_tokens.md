# Count tokens in text

Approximates the number of tokens using either a word-based or
character-based method.

## Usage

``` r
count_tokens(text, method = c("words", "chars"))
```

## Arguments

- text:

  Character string (or vector) to count tokens for.

- method:

  Counting method: `"words"` (default) multiplies word count by 1.3;
  `"chars"` divides character count by 4.

## Value

Numeric vector of token count estimates.

## Examples

``` r
count_tokens("Hello world, this is a test.")
#> [1] 8
```
