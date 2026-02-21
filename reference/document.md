# Create a document

Constructs an S3 object representing a text document with metadata.

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
#> <securecontext_document>
#>   id: doc_1ea7436c156f 
#>   chars: 11 
#>   metadata: source 
#>   text: Hello world 
```
