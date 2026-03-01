#' Knowledge Store
#'
#' Persistent JSONL key-value knowledge base. Each entry stores a key, value,
#' optional metadata, and timestamp.
#'
#' @return An R6 object of class `knowledge_store`.
#' @examples
#' ks <- knowledge_store$new()
#' ks$set("color", "blue", metadata = list(source = "test"))
#' ks$get("color")
#' ks$search("col")
#' ks$size()
#' @export
knowledge_store <- R6::R6Class(
  "knowledge_store",
  public = list(
    #' @description Create a new knowledge store.
    #' @param path Optional file path for JSONL persistence. `NULL` for
    #'   in-memory only.
    #' @param encryption_key Raw 32-byte key for AES-256-CBC encryption at rest,
    #'   or `NULL` to check the `SECURECONTEXT_ENCRYPTION_KEY` env var. If neither
    #'   is set, data is stored unencrypted.
    #' @param audit_log Optional path to a JSONL audit log file. If non-NULL,
    #'   store operations are logged via [log_store_event()].
    initialize = function(path = NULL, encryption_key = NULL, audit_log = NULL) {
      private$.path <- path
      private$.data <- list()
      private$.encryption_key <- resolve_encryption_key(encryption_key)
      private$.audit_log <- audit_log
      if (!is.null(path) && file.exists(path)) {
        self$load()
      }
    },

    #' @description Set a key-value pair (upsert).
    #' @param key Character key.
    #' @param value Any R object that can be serialized to JSON.
    #' @param metadata Named list of metadata.
    set = function(key, value, metadata = list()) {
      if (!is.character(key) || length(key) != 1L) {
        cli_abort("{.arg key} must be a single character string.")
      }
      private$.data[[key]] <- list(
        key = key,
        value = value,
        metadata = metadata,
        timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
      )
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "set", list(key = key))
      }
      if (!is.null(private$.path)) self$save()
      invisible(self)
    },

    #' @description Get a value by key.
    #' @param key Character key.
    #' @param default Value to return if key not found.
    #' @return The stored value, or `default`.
    get = function(key, default = NULL) {
      entry <- private$.data[[key]]
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "get", list(key = key))
      }
      if (is.null(entry)) default else entry$value
    },

    #' @description Delete a key.
    #' @param key Character key.
    delete = function(key) {
      private$.data[[key]] <- NULL
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "delete", list(key = key))
      }
      if (!is.null(private$.path)) self$save()
      invisible(self)
    },

    #' @description Search keys by regex pattern.
    #' @param pattern Regular expression.
    #' @return Character vector of matching keys.
    search = function(pattern) {
      keys <- names(private$.data)
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "search", list(pattern = pattern))
      }
      if (length(keys) == 0L) return(character())
      tryCatch(
        keys[grepl(pattern, keys)],
        warning = function(w) {
          cli_warn("Invalid regex pattern {.val {pattern}}: {conditionMessage(w)}")
          character()
        },
        error = function(e) {
          cli_warn("Invalid regex pattern {.val {pattern}}: {conditionMessage(e)}")
          character()
        }
      )
    },

    #' @description List all keys.
    #' @param n Optional maximum number to return.
    #' @return Character vector of keys.
    list = function(n = NULL) {
      keys <- names(private$.data)
      if (!is.null(n)) keys <- utils::head(keys, n)
      keys
    },

    #' @description Number of entries.
    #' @return Integer.
    size = function() {
      length(private$.data)
    },

    #' @description Save to JSONL file.
    save = function() {
      if (is.null(private$.path)) {
        cli_warn("No path set; nothing to save.")
        return(invisible(self))
      }
      lines <- vapply(private$.data, function(entry) {
        jsonlite::toJSON(entry, auto_unbox = TRUE)
      }, character(1L))
      if (!is.null(private$.encryption_key)) {
        raw_data <- charToRaw(paste(lines, collapse = "\n"))
        encrypted <- encrypt_raw(raw_data, private$.encryption_key)
        writeBin(encrypted, private$.path)
      } else {
        writeLines(lines, private$.path)
      }
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "save", list(path = private$.path))
      }
      invisible(self)
    },

    #' @description Load from JSONL file.
    load = function() {
      if (is.null(private$.path) || !file.exists(private$.path)) {
        cli_warn("No file to load.")
        return(invisible(self))
      }
      if (!is.null(private$.encryption_key)) {
        raw_data <- readBin(private$.path, "raw", file.info(private$.path)$size)
        decrypted <- decrypt_raw(raw_data, private$.encryption_key)
        text <- rawToChar(decrypted)
        lines <- strsplit(text, "\n")[[1L]]
      } else {
        lines <- readLines(private$.path, warn = FALSE)
      }
      lines <- lines[nzchar(trimws(lines))]
      private$.data <- list()
      for (line in lines) {
        entry <- jsonlite::fromJSON(line, simplifyVector = FALSE)
        private$.data[[entry$key]] <- entry
      }
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "load", list(path = private$.path))
      }
      invisible(self)
    }
  ),
  private = list(
    .path = NULL,
    .data = NULL,
    .encryption_key = NULL,
    .audit_log = NULL
  )
)
