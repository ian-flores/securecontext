# Resolve encryption key from parameter or environment

Checks for an explicit key first, then falls back to the
`SECURECONTEXT_ENCRYPTION_KEY` environment variable (hex-encoded).

## Usage

``` r
resolve_encryption_key(key = NULL)
```

## Arguments

- key:

  Raw key, or `NULL` to check env var.

## Value

Raw 32-byte key, or `NULL` if no encryption configured.
