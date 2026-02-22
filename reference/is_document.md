# Test if object is a document

Test if object is a document

## Usage

``` r
is_document(x)
```

## Arguments

- x:

  Object to test.

## Value

Logical.

## Examples

``` r
doc <- document("Hello world")
is_document(doc)
#> [1] TRUE
is_document("not a doc")
#> [1] FALSE
```
