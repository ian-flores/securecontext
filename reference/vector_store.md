# Vector Store

Vector Store

Vector Store

## Value

An R6 object of class `vector_store`.

## Details

In-memory vector store with cosine similarity search and RDS
persistence.

## Methods

### Public methods

- [`vector_store$new()`](#method-vector_store-new)

- [`vector_store$add()`](#method-vector_store-add)

- [`vector_store$search()`](#method-vector_store-search)

- [`vector_store$remove()`](#method-vector_store-remove)

- [`vector_store$size()`](#method-vector_store-size)

- [`vector_store$save()`](#method-vector_store-save)

- [`vector_store$load()`](#method-vector_store-load)

- [`vector_store$clone()`](#method-vector_store-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new vector store.

#### Usage

    vector_store$new(dims, encryption_key = NULL, audit_log = NULL)

#### Arguments

- `dims`:

  Integer, dimensionality of stored vectors.

- `encryption_key`:

  Raw 32-byte key for AES-256-CBC encryption at rest, or `NULL` to check
  the `SECURECONTEXT_ENCRYPTION_KEY` env var. If neither is set, data is
  stored unencrypted.

- `audit_log`:

  Optional path to a JSONL audit log file. If non-NULL, store operations
  are logged via
  [`log_store_event()`](https://ian-flores.github.io/securecontext/reference/log_store_event.md).

------------------------------------------------------------------------

### Method `add()`

Add vectors to the store.

#### Usage

    vector_store$add(ids, embeddings, metadata = list())

#### Arguments

- `ids`:

  Character vector of unique identifiers.

- `embeddings`:

  Numeric matrix (nrow = length(ids), ncol = dims).

- `metadata`:

  List of metadata entries (one per id), or empty list.

------------------------------------------------------------------------

### Method [`search()`](https://rdrr.io/r/base/search.html)

Search for nearest neighbors by cosine similarity.

#### Usage

    vector_store$search(query_embedding, k = 5L)

#### Arguments

- `query_embedding`:

  Numeric vector or single-row matrix.

- `k`:

  Number of results to return.

#### Returns

Data frame with columns `id`, `score`, and `metadata`.

------------------------------------------------------------------------

### Method [`remove()`](https://rdrr.io/r/base/rm.html)

Remove vectors by id.

#### Usage

    vector_store$remove(ids)

#### Arguments

- `ids`:

  Character vector of ids to remove.

------------------------------------------------------------------------

### Method `size()`

Number of stored vectors.

#### Usage

    vector_store$size()

#### Returns

Integer.

------------------------------------------------------------------------

### Method [`save()`](https://rdrr.io/r/base/save.html)

Save store to an RDS file.

#### Usage

    vector_store$save(path)

#### Arguments

- `path`:

  File path.

------------------------------------------------------------------------

### Method [`load()`](https://rdrr.io/r/base/load.html)

Load store from an RDS file.

#### Usage

    vector_store$load(path)

#### Arguments

- `path`:

  File path.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    vector_store$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
vs <- vector_store$new(dims = 3L)
vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
vs$add("id2", matrix(c(0, 1, 0), nrow = 1))
vs$search(c(1, 0, 0), k = 1)
#>    id score
#> 1 id1     1
vs$size()
#> [1] 2
```
