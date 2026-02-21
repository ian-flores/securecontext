#' Create a retriever
#'
#' Wraps a [vector_store] and an embedder for semantic retrieval.
#'
#' @param store A [vector_store] object.
#' @param embedder A `securecontext_embedder` object.
#' @return A `securecontext_retriever` object.
#' @export
retriever <- function(store, embedder) {
  if (!inherits(store, "vector_store")) {
    cli_abort("{.arg store} must be a {.cls vector_store}.")
  }
  if (!inherits(embedder, "securecontext_embedder")) {
    cli_abort("{.arg embedder} must be a {.cls securecontext_embedder}.")
  }
  structure(
    list(store = store, embedder = embedder),
    class = "securecontext_retriever"
  )
}

#' Retrieve relevant chunks
#'
#' Embeds the query, searches the vector store, and returns results.
#'
#' @param ret A `securecontext_retriever` object.
#' @param query Character string query.
#' @param k Number of results.
#' @return Data frame with columns `id`, `score`.
#' @export
retrieve <- function(ret, query, k = 5L) {
  if (!inherits(ret, "securecontext_retriever")) {
    cli_abort("{.arg ret} must be a {.cls securecontext_retriever}.")
  }
  query_emb <- embed_texts(ret$embedder, query)
  ret$store$search(query_emb, k = k)
}

#' Add documents to a retriever
#'
#' Chunks documents, embeds the chunks, and adds them to the vector store.
#'
#' @param ret A `securecontext_retriever` object.
#' @param documents A list of `securecontext_document` objects, or a single
#'   document.
#' @param chunk_strategy Chunking strategy (see [chunk_text()]).
#' @param ... Additional arguments passed to [chunk_text()].
#' @return The retriever, invisibly.
#' @export
add_documents <- function(ret, documents, chunk_strategy = "recursive", ...) {
  if (!inherits(ret, "securecontext_retriever")) {
    cli_abort("{.arg ret} must be a {.cls securecontext_retriever}.")
  }
  if (is_document(documents)) {
    documents <- list(documents)
  }

  all_chunks <- character()
  all_ids <- character()
  all_meta <- list()

  for (doc in documents) {
    if (!is_document(doc)) {
      cli_abort("Each element must be a {.cls securecontext_document}.")
    }
    chunks <- chunk_text(doc$text, strategy = chunk_strategy, ...)
    n <- length(chunks)
    if (n == 0L) next
    ids <- paste0(doc$id, "_chunk_", seq_len(n))
    meta <- lapply(seq_len(n), function(i) {
      c(doc$metadata, list(doc_id = doc$id, chunk_index = i, chunk_text = chunks[i]))
    })
    all_chunks <- c(all_chunks, chunks)
    all_ids <- c(all_ids, ids)
    all_meta <- c(all_meta, meta)
  }

  if (length(all_chunks) > 0L) {
    embs <- embed_texts(ret$embedder, all_chunks)
    ret$store$add(all_ids, embs, all_meta)
  }
  invisible(ret)
}
