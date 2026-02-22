# Wrap knowledge store as orchestr-compatible memory

If the orchestr package is available, wraps a
[knowledge_store](https://ian-flores.github.io/securecontext/reference/knowledge_store.md)
so it can be used in orchestr agent graphs.

## Usage

``` r
as_orchestr_memory(ks)
```

## Arguments

- ks:

  A
  [knowledge_store](https://ian-flores.github.io/securecontext/reference/knowledge_store.md)
  object.

## Value

A list with `get` and `set` functions compatible with orchestr memory
interface.

## Examples

``` r
ks <- knowledge_store$new()
mem <- as_orchestr_memory(ks)
mem$set("key", "value")
mem$get("key")
#> [1] "value"
```
