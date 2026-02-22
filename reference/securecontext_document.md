# S7 class for securecontext documents

S7 class for securecontext documents

## Usage

``` r
securecontext_document(
  text = character(0),
  metadata = list(),
  id = character(0)
)
```

## Arguments

- text:

  Character string of document content.

- metadata:

  Named list of arbitrary metadata.

- id:

  Character string document identifier.

## Examples

``` r
doc <- securecontext_document(
  text = "Sample text", metadata = list(source = "test"), id = "doc1"
)
doc@text
#> [1] "Sample text"
```
