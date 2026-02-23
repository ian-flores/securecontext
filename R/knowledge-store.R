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
    initialize = function(path = NULL) {
      private$.path <- path
      private$.data <- list()
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
      if (!is.null(private$.path)) self$save()
      invisible(self)
    },

    #' @description Get a value by key.
    #' @param key Character key.
    #' @param default Value to return if key not found.
    #' @return The stored value, or `default`.
    get = function(key, default = NULL) {
      entry <- private$.data[[key]]
      if (is.null(entry)) default else entry$value
    },

    #' @description Delete a key.
    #' @param key Character key.
    delete = function(key) {
      private$.data[[key]] <- NULL
      if (!is.null(private$.path)) self$save()
      invisible(self)
    },

    #' @description Search keys by regex pattern.
    #' @param pattern Regular expression.
    #' @return Character vector of matching keys.
    search = function(pattern) {
      keys <- names(private$.data)
      if (length(keys) == 0L) return(character())
      keys[grepl(pattern, keys)]
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
      writeLines(lines, private$.path)
      invisible(self)
    },

    #' @description Load from JSONL file.
    load = function() {
      if (is.null(private$.path) || !file.exists(private$.path)) {
        cli_warn("No file to load.")
        return(invisible(self))
      }
      lines <- readLines(private$.path, warn = FALSE)
      lines <- lines[nzchar(trimws(lines))]
      private$.data <- list()
      for (line in lines) {
        entry <- jsonlite::fromJSON(line, simplifyVector = FALSE)
        private$.data[[entry$key]] <- entry
      }
      invisible(self)
    }
  ),
  private = list(
    .path = NULL,
    .data = NULL
  )
)
