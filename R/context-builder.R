#' Create a context builder
#'
#' Token-aware context assembly with priority-based inclusion.
#'
#' @param max_tokens Maximum number of tokens for the assembled context.
#' @return A `securecontext_context_builder` object.
#' @export
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb <- cb_add(cb, "Important info", priority = 10)
#' cb <- cb_add(cb, "Less important", priority = 1)
#' result <- cb_build(cb)
context_builder <- function(max_tokens = 4000L) {
  structure(
    list(
      max_tokens = as.integer(max_tokens),
      items = list()
    ),
    class = "securecontext_context_builder"
  )
}

#' Add content to a context builder
#'
#' @param builder A `securecontext_context_builder`.
#' @param text Character string to add.
#' @param priority Numeric priority (higher = included first).
#' @param label Optional label for tracking what was included/excluded.
#' @return Updated builder.
#' @export
cb_add <- function(builder, text, priority = 1, label = NULL) {
  if (!inherits(builder, "securecontext_context_builder")) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  if (is.null(label)) {
    label <- paste0("item_", length(builder$items) + 1L)
  }
  item <- list(
    text = text,
    priority = priority,
    label = label,
    tokens = count_tokens(text)
  )
  builder$items <- c(builder$items, list(item))
  builder
}

#' Build the context string
#'
#' Assembles context by including highest-priority items first until the token
#' limit is reached.
#'
#' @param builder A `securecontext_context_builder`.
#' @return A list with elements `context` (assembled string), `included`
#'   (labels of included items), `excluded` (labels of excluded items), and
#'   `total_tokens` (token count of assembled context).
#' @export
cb_build <- function(builder) {
  if (!inherits(builder, "securecontext_context_builder")) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  if (length(builder$items) == 0L) {
    return(list(
      context = "",
      included = character(),
      excluded = character(),
      total_tokens = 0L
    ))
  }

  # Sort by priority descending
  priorities <- vapply(builder$items, function(x) x$priority, double(1L))
  ord <- order(priorities, decreasing = TRUE)

  included <- character()
  excluded <- character()
  parts <- character()
  used_tokens <- 0L

  for (i in ord) {
    item <- builder$items[[i]]
    if (used_tokens + item$tokens <= builder$max_tokens) {
      parts <- c(parts, item$text)
      used_tokens <- used_tokens + item$tokens
      included <- c(included, item$label)
    } else {
      excluded <- c(excluded, item$label)
    }
  }

  list(
    context = paste(parts, collapse = "\n\n"),
    included = included,
    excluded = excluded,
    total_tokens = used_tokens
  )
}

#' Reset a context builder
#'
#' Removes all added content.
#'
#' @param builder A `securecontext_context_builder`.
#' @return Reset builder.
#' @export
cb_reset <- function(builder) {
  if (!inherits(builder, "securecontext_context_builder")) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  builder$items <- list()
  builder
}
