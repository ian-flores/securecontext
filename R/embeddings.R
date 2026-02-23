#' S7 class for securecontext embedders
#'
#' @param embed_fn A function taking a character vector and returning a numeric
#'   matrix.
#' @param dims Integer, the dimensionality of the embedding space.
#' @return A `securecontext_embedder` S7 object.
#' @name securecontext_embedder
#' @examples
#' emb <- embed_tfidf(c("hello world", "goodbye world"))
#' emb@dims
#' @export
securecontext_embedder <- new_class("securecontext_embedder", properties = list(
  embed_fn = class_function,
  dims = class_integer
))

#' Create an embedder
#'
#' Constructs an embedder object from a function and dimensionality.
#'
#' @param embed_fn A function taking a character vector and returning a numeric
#'   matrix with one row per text and `dims` columns.
#' @param dims Integer, the dimensionality of the embedding space.
#' @return A `securecontext_embedder` object.
#' @export
#' @examples
#' # Create a simple random embedder
#' random_embed <- function(texts) matrix(runif(length(texts) * 3), ncol = 3)
#' emb <- new_embedder(random_embed, dims = 3L)
#' emb@dims
new_embedder <- function(embed_fn, dims) {
  if (!is.function(embed_fn)) {
    cli_abort("{.arg embed_fn} must be a function.")
  }
  dims <- as.integer(dims)
  securecontext_embedder(embed_fn = embed_fn, dims = dims)
}

#' Create a TF-IDF embedder
#'
#' Builds a TF-IDF vocabulary from a corpus and returns an embedder that can
#' embed new texts into that vocabulary space. No external API required.
#'
#' @param corpus Character vector of documents to build vocabulary from.
#' @return A `securecontext_embedder` object.
#' @export
#' @examples
#' emb <- embed_tfidf(c("the cat sat", "the dog ran"))
embed_tfidf <- function(corpus) {
  if (!is.character(corpus) || length(corpus) == 0L) {
    cli_abort("{.arg corpus} must be a non-empty character vector.")
  }

  # Tokenize
  tokenize <- function(texts) {
    lapply(texts, function(txt) {
      tokens <- strsplit(tolower(trimws(txt)), "\\s+")[[1L]]
      tokens[nzchar(tokens)]
    })
  }

  corpus_tokens <- tokenize(corpus)
  n_docs <- length(corpus)

  # Build vocabulary
  vocab <- sort(unique(unlist(corpus_tokens)))
  if (length(vocab) == 0L) {
    cli_abort("Corpus produced an empty vocabulary.")
  }
  vocab_index <- stats::setNames(seq_along(vocab), vocab)

  # Compute IDF: log(N / df) where df = number of docs containing term
  doc_freq <- integer(length(vocab))
  for (tokens in corpus_tokens) {
    present <- unique(tokens)
    idx <- vocab_index[present]
    idx <- idx[!is.na(idx)]
    doc_freq[idx] <- doc_freq[idx] + 1L
  }
  idf <- log(n_docs / pmax(doc_freq, 1L))

  dims <- length(vocab)

  embed_fn <- function(texts) {
    tok_list <- tokenize(texts)
    mat <- matrix(0, nrow = length(texts), ncol = dims)
    for (i in seq_along(tok_list)) {
      tokens <- tok_list[[i]]
      if (length(tokens) == 0L) next
      # Term frequency
      tab <- table(tokens)
      idx <- vocab_index[names(tab)]
      valid <- !is.na(idx)
      if (!any(valid)) next
      mat[i, idx[valid]] <- as.numeric(tab[valid]) * idf[idx[valid]]
    }
    # Normalize rows to unit length
    norms <- sqrt(rowSums(mat^2))
    norms[norms == 0] <- 1
    mat / norms
  }

  new_embedder(embed_fn, dims)
}

#' Embed texts using an embedder
#'
#' @param embedder A `securecontext_embedder` object.
#' @param texts Character vector of texts to embed.
#' @return Numeric matrix with `length(texts)` rows and `embedder@@dims` columns.
#' @export
#' @examples
#' emb <- embed_tfidf(c("the cat sat", "the dog ran"))
#' mat <- embed_texts(emb, c("cat sat", "dog ran"))
#' nrow(mat)
embed_texts <- function(embedder, texts) {
  if (!S7_inherits(embedder, securecontext_embedder)) {
    cli_abort("{.arg embedder} must be a {.cls securecontext_embedder}.")
  }
  if (!is.character(texts)) {
    cli_abort("{.arg texts} must be a character vector.")
  }
  embedder@embed_fn(texts)
}
