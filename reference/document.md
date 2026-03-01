# Create a document

Constructs an S7 object representing a text document with metadata.

## Usage

``` r
document(text, metadata = list(), id = NULL)
```

## Arguments

- text:

  Character string of document content.

- metadata:

  Named list of arbitrary metadata.

- id:

  Optional document identifier. Generated if `NULL`.

## Value

A `securecontext_document` object.

## Examples

``` r
doc <- document("Hello world", metadata = list(source = "test"))
doc
#> <securecontext::securecontext_document>
#>  @ text    : chr "Hello world"
#>  @ metadata:List of 1
#>  .. $ source: chr "test"
#>  @ id      : chr "doc_20260301144159_5e9f4103"
```
