# Paragraph-based text chunking

Splits text on double newlines.

## Usage

``` r
chunk_paragraph(text)
```

## Arguments

- text:

  Character string to chunk.

## Value

Character vector of paragraph chunks.

## Examples

``` r
chunk_paragraph("First paragraph.\n\nSecond paragraph.\n\nThird.")
#> [1] "First paragraph."  "Second paragraph." "Third."           
```
