# Add content to a context builder

Add content to a context builder

## Usage

``` r
cb_add(builder, text, priority = 1, label = NULL)
```

## Arguments

- builder:

  A `securecontext_context_builder`.

- text:

  Character string to add.

- priority:

  Numeric priority (higher = included first).

- label:

  Optional label for tracking what was included/excluded.

## Value

Updated builder.

## Examples

``` r
cb <- context_builder(max_tokens = 100)
cb <- cb_add(cb, "High priority text", priority = 10, label = "important")
cb <- cb_add(cb, "Low priority text", priority = 1, label = "filler")
```
