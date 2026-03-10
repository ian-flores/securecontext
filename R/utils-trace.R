# Internal tracing helpers -- not exported
# securetrace is a soft dependency (Suggests only)

#' Check if securetrace is active
#' @return Logical scalar.
#' @noRd
.trace_active <- function() {
  requireNamespace("securetrace", quietly = TRUE) &&
    !is.null(securetrace::current_trace())
}

#' Add an event to the current span (if tracing)
#' @param name Event name.
#' @param data Named list of event data.
#' @return Invisible `NULL`.
#' @noRd
.span_event <- function(name, data = list()) {
  if (.trace_active()) {
    span <- securetrace::current_span()
    if (!is.null(span)) {
      span$add_event(securetrace::trace_event(name, data))
    }
  }
  invisible(NULL)
}
