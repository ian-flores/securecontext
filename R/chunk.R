#' Chunk text into smaller pieces
#'
#' Splits text using the specified strategy.
#'
#' @param text Character string to chunk.
#' @param strategy Chunking strategy: `"fixed"`, `"sentence"`, `"paragraph"`,
#'   or `"recursive"`.
#' @param ... Additional arguments passed to the strategy function.
#' @return Character vector of chunks.
#' @export
#' @examples
#' chunks <- chunk_text("Hello world. How are you?", strategy = "sentence")
chunk_text <- function(text, strategy = c("fixed", "sentence", "paragraph", "recursive"), ...) {
  strategy <- match.arg(strategy)
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  switch(strategy,
    fixed = chunk_fixed(text, ...),
    sentence = chunk_sentence(text, ...),
    paragraph = chunk_paragraph(text, ...),
    recursive = chunk_recursive(text, ...)
  )
}

#' Fixed-size text chunking
#'
#' Splits text into chunks of approximately `size` characters with optional
#' overlap.
#'
#' @param text Character string to chunk.
#' @param size Target chunk size in characters.
#' @param overlap Number of overlap characters between consecutive chunks.
#' @return Character vector of chunks.
#' @export
chunk_fixed <- function(text, size = 500L, overlap = 50L) {
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  n <- nchar(text)
  if (n == 0L) return(character(0L))
  size <- as.integer(size)
  overlap <- as.integer(overlap)
  if (overlap >= size) {
    cli_abort("{.arg overlap} must be less than {.arg size}.")
  }
  if (n <= size) return(text)

  chunks <- character()
  start <- 1L
  step <- size - overlap
  while (start <= n) {
    end <- min(start + size - 1L, n)
    chunks <- c(chunks, substr(text, start, end))
    start <- start + step
    if (end == n) break
  }
  chunks
}

#' Sentence-based text chunking
#'
#' Splits text on sentence boundaries (period followed by space or newline).
#'
#' @param text Character string to chunk.
#' @return Character vector of sentence chunks.
#' @export
chunk_sentence <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  if (nchar(text) == 0L) return(character(0L))
  parts <- strsplit(text, "(?<=\\.)\\s+", perl = TRUE)[[1L]]
  parts <- trimws(parts)
  parts[nzchar(parts)]
}

#' Paragraph-based text chunking
#'
#' Splits text on double newlines.
#'
#' @param text Character string to chunk.
#' @return Character vector of paragraph chunks.
#' @export
chunk_paragraph <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  if (nchar(text) == 0L) return(character(0L))
  parts <- strsplit(text, "\n\\s*\n", perl = TRUE)[[1L]]
  parts <- trimws(parts)
  parts[nzchar(parts)]
}

#' Recursive text chunking
#'
#' Recursively splits text using a hierarchy of separators, similar to
#' LangChain's recursive text splitter.
#'
#' @param text Character string to chunk.
#' @param max_size Maximum chunk size in characters.
#' @param separators Character vector of separators to try in order.
#' @return Character vector of chunks.
#' @export
chunk_recursive <- function(text, max_size = 500L, separators = c("\n\n", "\n", ". ", " ")) {
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  max_size <- as.integer(max_size)
  if (nchar(text) == 0L) return(character(0L))
  if (nchar(text) <= max_size) return(text)

  .recursive_split(text, max_size, separators)
}

.recursive_split <- function(text, max_size, separators) {
  if (nchar(text) <= max_size) return(text)
  if (length(separators) == 0L) {
    return(chunk_fixed(text, size = max_size, overlap = 0L))
  }

  sep <- separators[1L]
  parts <- strsplit(text, sep, fixed = TRUE)[[1L]]
  parts <- trimws(parts)
  parts <- parts[nzchar(parts)]

  if (length(parts) <= 1L) {
    return(.recursive_split(text, max_size, separators[-1L]))
  }

  chunks <- character()
  for (part in parts) {
    if (nchar(part) <= max_size) {
      chunks <- c(chunks, part)
    } else {
      chunks <- c(chunks, .recursive_split(part, max_size, separators[-1L]))
    }
  }
  chunks
}
