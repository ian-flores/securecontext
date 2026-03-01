#' Vector Store
#'
#' In-memory vector store with cosine similarity search and RDS persistence.
#'
#' @return An R6 object of class `vector_store`.
#' @examples
#' vs <- vector_store$new(dims = 3L)
#' vs$add("id1", matrix(c(1, 0, 0), nrow = 1))
#' vs$add("id2", matrix(c(0, 1, 0), nrow = 1))
#' vs$search(c(1, 0, 0), k = 1)
#' vs$size()
#' @export
vector_store <- R6::R6Class(
  "vector_store",
  public = list(
    #' @description Create a new vector store.
    #' @param dims Integer, dimensionality of stored vectors.
    #' @param encryption_key Raw 32-byte key for AES-256-CBC encryption at rest,
    #'   or `NULL` to check the `SECURECONTEXT_ENCRYPTION_KEY` env var. If neither
    #'   is set, data is stored unencrypted.
    #' @param audit_log Optional path to a JSONL audit log file. If non-NULL,
    #'   store operations are logged via [log_store_event()].
    initialize = function(dims, encryption_key = NULL, audit_log = NULL) {
      private$.dims <- as.integer(dims)
      private$.ids <- character()
      private$.embeddings <- matrix(numeric(0L), nrow = 0L, ncol = private$.dims)
      private$.metadata <- list()
      private$.encryption_key <- resolve_encryption_key(encryption_key)
      private$.audit_log <- audit_log
    },

    #' @description Add vectors to the store.
    #' @param ids Character vector of unique identifiers.
    #' @param embeddings Numeric matrix (nrow = length(ids), ncol = dims).
    #' @param metadata List of metadata entries (one per id), or empty list.
    add = function(ids, embeddings, metadata = list()) {
      if (!is.character(ids)) {
        cli_abort("{.arg ids} must be a character vector.")
      }
      if (!is.matrix(embeddings) || ncol(embeddings) != private$.dims) {
        cli_abort("{.arg embeddings} must be a matrix with {private$.dims} columns.")
      }
      if (nrow(embeddings) != length(ids)) {
        cli_abort("Number of rows in {.arg embeddings} must match length of {.arg ids}.")
      }

      # Normalize rows
      norms <- sqrt(rowSums(embeddings^2))
      norms[norms == 0] <- 1
      embeddings <- embeddings / norms

      if (length(metadata) == 0L) {
        metadata <- rep(list(list()), length(ids))
      }

      # Remove duplicates
      existing <- ids %in% private$.ids
      if (any(existing)) {
        self$remove(ids[existing])
      }

      private$.ids <- c(private$.ids, ids)
      private$.embeddings <- rbind(private$.embeddings, embeddings)
      private$.metadata <- c(private$.metadata, metadata)
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "add", list(ids = ids))
      }
      invisible(self)
    },

    #' @description Search for nearest neighbors by cosine similarity.
    #' @param query_embedding Numeric vector or single-row matrix.
    #' @param k Number of results to return.
    #' @return Data frame with columns `id`, `score`, and `metadata`.
    search = function(query_embedding, k = 5L) {
      if (is.matrix(query_embedding)) {
        query_embedding <- as.numeric(query_embedding[1L, ])
      }
      if (length(query_embedding) != private$.dims) {
        cli_abort("Query embedding must have length {private$.dims}.")
      }
      if (self$size() == 0L) {
        return(data.frame(id = character(), score = numeric(), stringsAsFactors = FALSE))
      }

      # Normalize query
      qnorm <- sqrt(sum(query_embedding^2))
      if (qnorm > 0) query_embedding <- query_embedding / qnorm

      scores <- as.numeric(private$.embeddings %*% query_embedding)
      k <- min(k, length(scores))
      top_idx <- order(scores, decreasing = TRUE)[seq_len(k)]

      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "search", list(k = k))
      }

      data.frame(
        id = private$.ids[top_idx],
        score = scores[top_idx],
        stringsAsFactors = FALSE
      )
    },

    #' @description Remove vectors by id.
    #' @param ids Character vector of ids to remove.
    remove = function(ids) {
      keep <- !(private$.ids %in% ids)
      private$.ids <- private$.ids[keep]
      private$.embeddings <- private$.embeddings[keep, , drop = FALSE]
      private$.metadata <- private$.metadata[keep]
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "remove", list(ids = ids))
      }
      invisible(self)
    },

    #' @description Number of stored vectors.
    #' @return Integer.
    size = function() {
      length(private$.ids)
    },

    #' @description Save store to an RDS file.
    #' @param path File path.
    save = function(path) {
      data <- list(
        dims = private$.dims,
        ids = private$.ids,
        embeddings = private$.embeddings,
        metadata = private$.metadata
      )
      if (!is.null(private$.encryption_key)) {
        raw_data <- serialize(data, NULL)
        encrypted <- encrypt_raw(raw_data, private$.encryption_key)
        writeBin(encrypted, path)
      } else {
        saveRDS(data, path)
      }
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "save", list(path = path))
      }
      invisible(self)
    },

    #' @description Load store from an RDS file.
    #' @param path File path.
    load = function(path) {
      if (!is.null(private$.encryption_key)) {
        raw_data <- readBin(path, "raw", file.info(path)$size)
        decrypted <- decrypt_raw(raw_data, private$.encryption_key)
        data <- unserialize(decrypted)
      } else {
        data <- readRDS(path)
      }
      if (!is.list(data)) {
        cli_abort("Invalid vector store file: expected a list, got {.cls {class(data)}}.")
      }
      required <- c("dims", "ids", "embeddings", "metadata")
      missing_fields <- setdiff(required, names(data))
      if (length(missing_fields) > 0L) {
        cli_abort(
          "Invalid vector store file: missing required fields {.val {missing_fields}}."
        )
      }
      # Type validation
      if (!is.numeric(data$dims) || length(data$dims) != 1L) {
        cli_abort("Invalid vector store file: {.field dims} must be a single integer.")
      }
      if (!is.character(data$ids)) {
        cli_abort("Invalid vector store file: {.field ids} must be a character vector.")
      }
      if (!is.matrix(data$embeddings) || !is.numeric(data$embeddings)) {
        cli_abort("Invalid vector store file: {.field embeddings} must be a numeric matrix.")
      }
      if (!is.list(data$metadata)) {
        cli_abort("Invalid vector store file: {.field metadata} must be a list.")
      }
      private$.dims <- data$dims
      private$.ids <- data$ids
      private$.embeddings <- data$embeddings
      private$.metadata <- data$metadata
      if (!is.null(private$.audit_log)) {
        log_store_event(private$.audit_log, "load", list(path = path))
      }
      invisible(self)
    }
  ),
  private = list(
    .dims = NULL,
    .ids = NULL,
    .embeddings = NULL,
    .metadata = NULL,
    .encryption_key = NULL,
    .audit_log = NULL
  )
)
