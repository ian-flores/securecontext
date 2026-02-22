# Knowledge Store

Knowledge Store

Knowledge Store

## Details

Persistent JSONL key-value knowledge base. Each entry stores a key,
value, optional metadata, and timestamp.

## Methods

### Public methods

- [`knowledge_store$new()`](#method-knowledge_store-new)

- [`knowledge_store$set()`](#method-knowledge_store-set)

- [`knowledge_store$get()`](#method-knowledge_store-get)

- [`knowledge_store$delete()`](#method-knowledge_store-delete)

- [`knowledge_store$search()`](#method-knowledge_store-search)

- [`knowledge_store$list()`](#method-knowledge_store-list)

- [`knowledge_store$size()`](#method-knowledge_store-size)

- [`knowledge_store$save()`](#method-knowledge_store-save)

- [`knowledge_store$load()`](#method-knowledge_store-load)

- [`knowledge_store$clone()`](#method-knowledge_store-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new knowledge store.

#### Usage

    knowledge_store$new(path = NULL)

#### Arguments

- `path`:

  Optional file path for JSONL persistence. `NULL` for in-memory only.

------------------------------------------------------------------------

### Method `set()`

Set a key-value pair (upsert).

#### Usage

    knowledge_store$set(key, value, metadata = list())

#### Arguments

- `key`:

  Character key.

- `value`:

  Any R object that can be serialized to JSON.

- `metadata`:

  Named list of metadata.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get a value by key.

#### Usage

    knowledge_store$get(key, default = NULL)

#### Arguments

- `key`:

  Character key.

- `default`:

  Value to return if key not found.

#### Returns

The stored value, or `default`.

------------------------------------------------------------------------

### Method `delete()`

Delete a key.

#### Usage

    knowledge_store$delete(key)

#### Arguments

- `key`:

  Character key.

------------------------------------------------------------------------

### Method [`search()`](https://rdrr.io/r/base/search.html)

Search keys by regex pattern.

#### Usage

    knowledge_store$search(pattern)

#### Arguments

- `pattern`:

  Regular expression.

#### Returns

Character vector of matching keys.

------------------------------------------------------------------------

### Method [`list()`](https://rdrr.io/r/base/list.html)

List all keys.

#### Usage

    knowledge_store$list(n = NULL)

#### Arguments

- `n`:

  Optional maximum number to return.

#### Returns

Character vector of keys.

------------------------------------------------------------------------

### Method `size()`

Number of entries.

#### Usage

    knowledge_store$size()

#### Returns

Integer.

------------------------------------------------------------------------

### Method [`save()`](https://rdrr.io/r/base/save.html)

Save to JSONL file.

#### Usage

    knowledge_store$save()

------------------------------------------------------------------------

### Method [`load()`](https://rdrr.io/r/base/load.html)

Load from JSONL file.

#### Usage

    knowledge_store$load()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    knowledge_store$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
ks <- knowledge_store$new()
ks$set("color", "blue", metadata = list(source = "test"))
ks$get("color")
#> [1] "blue"
ks$search("col")
#> [1] "color"
ks$size()
#> [1] 1
```
