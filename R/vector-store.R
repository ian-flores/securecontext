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
    initialize = function(dims) {
      private$.dims <- as.integer(dims)
      private$.ids <- character()
      private$.embeddings <- matrix(numeric(0L), nrow = 0L, ncol = private$.dims)
      private$.metadata <- list()
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
      saveRDS(list(
        dims = private$.dims,
        ids = private$.ids,
        embeddings = private$.embeddings,
        metadata = private$.metadata
      ), path)
      invisible(self)
    },

    #' @description Load store from an RDS file.
    #' @param path File path.
    load = function(path) {
      data <- readRDS(path)
      private$.dims <- data$dims
      private$.ids <- data$ids
      private$.embeddings <- data$embeddings
      private$.metadata <- data$metadata
      invisible(self)
    }
  ),
  private = list(
    .dims = NULL,
    .ids = NULL,
    .embeddings = NULL,
    .metadata = NULL
  )
)
