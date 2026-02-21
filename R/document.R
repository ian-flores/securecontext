#' Create a document
#'
#' Constructs an S3 object representing a text document with metadata.
#'
#' @param text Character string of document content.
#' @param metadata Named list of arbitrary metadata.
#' @param id Optional document identifier. Generated if `NULL`.
#' @return A `securecontext_document` object.
#' @export
#' @examples
#' doc <- document("Hello world", metadata = list(source = "test"))
#' doc
document <- function(text, metadata = list(), id = NULL) {
  if (!is.character(text) || length(text) != 1L) {
    cli_abort("{.arg text} must be a single character string.")
  }
  if (!is.list(metadata)) {
    cli_abort("{.arg metadata} must be a list.")
  }
  if (is.null(id)) {
    id <- paste0("doc_", substr(tempfile(pattern = ""), nchar(tempdir()) + 2L, 100L))
  }
  structure(
    list(text = text, metadata = metadata, id = id),
    class = "securecontext_document"
  )
}

#' Test if object is a document
#'
#' @param x Object to test.
#' @return Logical.
#' @export
is_document <- function(x) {
  inherits(x, "securecontext_document")
}

#' @export
print.securecontext_document <- function(x, ...) {
  n <- nchar(x$text)
  preview <- if (n > 80L) paste0(substr(x$text, 1L, 77L), "...") else x$text
  cat("<securecontext_document>\n")
  cat("  id:", x$id, "\n")
  cat("  chars:", n, "\n")

  if (length(x$metadata) > 0L) {
    cat("  metadata:", paste(names(x$metadata), collapse = ", "), "\n")
  }
  cat("  text:", preview, "\n")
  invisible(x)
}
