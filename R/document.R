#' S7 class for securecontext documents
#'
#' @param text Character string of document content.
#' @param metadata Named list of arbitrary metadata.
#' @param id Character string document identifier.
#' @name securecontext_document
#' @examples
#' doc <- securecontext_document(
#'   text = "Sample text", metadata = list(source = "test"), id = "doc1"
#' )
#' doc@text
#' @export
securecontext_document <- new_class("securecontext_document", properties = list(
  text = class_character,
  metadata = class_list,
  id = class_character
))

#' Create a document
#'
#' Constructs an S7 object representing a text document with metadata.
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
  securecontext_document(text = text, metadata = metadata, id = id)
}

#' Test if object is a document
#'
#' @param x Object to test.
#' @return Logical.
#' @export
#' @examples
#' doc <- document("Hello world")
#' is_document(doc)
#' is_document("not a doc")
is_document <- function(x) {
  S7_inherits(x, securecontext_document)
}

method(print, securecontext_document) <- function(x, ...) {
  n <- nchar(x@text)
  preview <- if (n > 80L) paste0(substr(x@text, 1L, 77L), "...") else x@text
  cat("<securecontext_document>\n")
  cat("  id:", x@id, "\n")
  cat("  chars:", n, "\n")

  if (length(x@metadata) > 0L) {
    cat("  metadata:", paste(names(x@metadata), collapse = ", "), "\n")
  }
  cat("  text:", preview, "\n")
  invisible(x)
}
