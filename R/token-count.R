#' Count tokens in text
#'
#' Approximates the number of tokens using either a word-based or
#' character-based method.
#'
#' @param text Character string (or vector) to count tokens for.
#' @param method Counting method: `"words"` (default) multiplies word count by
#'   1.3; `"chars"` divides character count by 4.
#' @return Numeric vector of token count estimates.
#' @export
#' @examples
#' count_tokens("Hello world, this is a test.")
count_tokens <- function(text, method = c("words", "chars")) {
  method <- match.arg(method)
  if (!is.character(text)) {
    cli_abort("{.arg text} must be a character vector.")
  }
  switch(method,
    words = {
      words <- vapply(strsplit(text, "\\s+"), function(x) {
        sum(nzchar(x))
      }, double(1L))
      ceiling(words * 1.3)
    },
    chars = {
      ceiling(nchar(text) / 4)
    }
  )
}

#' Estimate token count
#'
#' Alias for [count_tokens()] with the default `"words"` method.
#'
#' @inheritParams count_tokens
#' @return Numeric token count estimate.
#' @export
estimate_tokens <- function(text) {
  count_tokens(text, method = "words")
}
