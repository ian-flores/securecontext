# Log a store event to a JSONL audit file

Log a store event to a JSONL audit file

## Usage

``` r
log_store_event(path, event_type, details = list())
```

## Arguments

- path:

  Character. Path to the JSONL log file.

- event_type:

  Character. Type of event (e.g., "save", "load", "search", "put",
  "get", "remove").

- details:

  List. Additional event details.
