#' Wrap knowledge store as orchestr-compatible memory
#'
#' If the orchestr package is available, wraps a [knowledge_store] so it can
#' be used in orchestr agent graphs.
#'
#' @param ks A [knowledge_store] object.
#' @return A list with `get` and `set` functions compatible with orchestr
#'   memory interface.
#' @export
#' @examples
#' ks <- knowledge_store$new()
#' mem <- as_orchestr_memory(ks)
#' mem$set("key", "value")
#' mem$get("key")
as_orchestr_memory <- function(ks) {
  if (!inherits(ks, "knowledge_store")) {
    cli_abort("{.arg ks} must be a {.cls knowledge_store}.")
  }
  list(
    get = function(key, default = NULL) ks$get(key, default),
    set = function(key, value, metadata = list()) ks$set(key, value, metadata)
  )
}

#' Build context for LLM chat
#'
#' Convenience function that retrieves relevant chunks and builds a
#' token-limited context string.
#'
#' @param ret A `securecontext_retriever` object.
#' @param query Character string query.
#' @param max_tokens Maximum tokens for the context.
#' @param k Number of chunks to retrieve.
#' @return A list with `context`, `included`, `excluded`, and `total_tokens`.
#' @export
#' @examples
#' emb <- embed_tfidf(c("cat sat on mat", "dog ran in park"))
#' vs <- vector_store$new(dims = emb@dims)
#' ret <- retriever(vs, emb)
#' add_documents(ret, document("The cat sat on the mat."))
#' result <- context_for_chat(ret, "cat", max_tokens = 100, k = 2)
#' result$context
context_for_chat <- function(ret, query, max_tokens = 4000L, k = 10L) {
  if (!S7_inherits(ret, securecontext_retriever)) {
    cli_abort("{.arg ret} must be a {.cls securecontext_retriever}.")
  }
  results <- retrieve(ret, query, k = k)
  cb <- context_builder(max_tokens = max_tokens)

  if (nrow(results) > 0L) {
    for (i in seq_len(nrow(results))) {
      id <- results$id[i]
      score <- results$score[i]
      # Try to get chunk_text from store metadata
      store_meta <- ret@store$.__enclos_env__$private$.metadata
      idx <- which(ret@store$.__enclos_env__$private$.ids == id)
      chunk_text_val <- if (length(idx) > 0L && !is.null(store_meta[[idx]]$chunk_text)) {
        store_meta[[idx]]$chunk_text
      } else {
        id
      }
      cb <- cb_add(cb, chunk_text_val, priority = score, label = id)
    }
  }

  cb_build(cb)
}
