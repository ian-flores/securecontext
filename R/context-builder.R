#' S7 class for securecontext context builders
#'
#' @param max_tokens Integer, maximum number of tokens.
#' @param items List of content items with priority.
#' @return A `securecontext_context_builder` S7 object.
#' @name securecontext_context_builder
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb@max_tokens
#' @export
securecontext_context_builder <- new_class("securecontext_context_builder", properties = list(
  max_tokens = class_integer,
  items = class_list
))

#' Create a context builder
#'
#' Token-aware context assembly with priority-based inclusion.
#'
#' @param max_tokens Maximum number of tokens for the assembled context.
#' @return A `securecontext_context_builder` object.
#' @export
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb <- context_add(cb, "Important info", priority = 10)
#' cb <- context_add(cb, "Less important", priority = 1)
#' result <- context_build(cb)
context_builder <- function(max_tokens = 4000L) {
  securecontext_context_builder(
    max_tokens = as.integer(max_tokens),
    items = list()
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
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb <- context_add(cb, "High priority text", priority = 10, label = "important")
#' cb <- context_add(cb, "Low priority text", priority = 1, label = "filler")
context_add <- function(builder, text, priority = 1, label = NULL) {
  if (!S7_inherits(builder, securecontext_context_builder)) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  if (is.null(label)) {
    label <- paste0("item_", length(builder@items) + 1L)
  }
  item <- list(
    text = text,
    priority = priority,
    label = label,
    tokens = count_tokens(text)
  )
  items <- c(builder@items, list(item))
  securecontext_context_builder(
    max_tokens = builder@max_tokens,
    items = items
  )
}

#' @rdname context_add
#' @param ... Arguments passed to [context_add()].
#' @export
cb_add <- function(...) {
  lifecycle::deprecate_warn("0.2.0", "cb_add()", "context_add()")
  context_add(...)
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
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb <- context_add(cb, "Important info", priority = 10)
#' result <- context_build(cb)
#' result$context
context_build <- function(builder) {
  if (!S7_inherits(builder, securecontext_context_builder)) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  if (length(builder@items) == 0L) {
    return(list(
      context = "",
      included = character(),
      excluded = character(),
      total_tokens = 0L
    ))
  }

  .do_build <- function() {
    # Sort by priority descending
    priorities <- vapply(builder@items, function(x) x$priority, double(1L))
    ord <- order(priorities, decreasing = TRUE)

    included <- character()
    excluded <- character()
    parts <- character()
    used_tokens <- 0L

    for (i in ord) {
      item <- builder@items[[i]]
      if (used_tokens + item$tokens <= builder@max_tokens) {
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

  if (.trace_active()) {
    securetrace::with_span("context.build", type = "custom", {
      result <- .do_build()
      .span_event("build.complete", list(
        items_included = length(result$included),
        items_excluded = length(result$excluded),
        total_tokens = result$total_tokens
      ))
      result
    })
  } else {
    .do_build()
  }
}

#' @rdname context_build
#' @param ... Arguments passed to [context_build()].
#' @export
cb_build <- function(...) {
  lifecycle::deprecate_warn("0.2.0", "cb_build()", "context_build()")
  context_build(...)
}

#' Reset a context builder
#'
#' Removes all added content.
#'
#' @param builder A `securecontext_context_builder`.
#' @return Reset builder.
#' @export
#' @examples
#' cb <- context_builder(max_tokens = 100)
#' cb <- context_add(cb, "some text")
#' cb <- context_reset(cb)
#' length(cb@items)
context_reset <- function(builder) {
  if (!S7_inherits(builder, securecontext_context_builder)) {
    cli_abort("{.arg builder} must be a {.cls securecontext_context_builder}.")
  }
  securecontext_context_builder(
    max_tokens = builder@max_tokens,
    items = list()
  )
}

#' @rdname context_reset
#' @param ... Arguments passed to [context_reset()].
#' @export
cb_reset <- function(...) {
  lifecycle::deprecate_warn("0.2.0", "cb_reset()", "context_reset()")
  context_reset(...)
}

method(format, securecontext_context_builder) <- function(x, ...) {
  n_items <- length(x@items)
  paste0(
    "<securecontext_context_builder>\n",
    "  max_tokens: ", x@max_tokens, "\n",
    "  items: ", n_items
  )
}

method(print, securecontext_context_builder) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}
