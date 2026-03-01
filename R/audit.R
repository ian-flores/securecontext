#' Log a store event to a JSONL audit file
#'
#' @param path Character. Path to the JSONL log file.
#' @param event_type Character. Type of event (e.g., "save", "load", "search", "put", "get", "remove").
#' @param details List. Additional event details.
#' @keywords internal
log_store_event <- function(path, event_type, details = list()) {
  entry <- c(
    list(
      timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
      event = event_type
    ),
    details
  )
  line <- jsonlite::toJSON(entry, auto_unbox = TRUE)
  cat(line, "\n", file = path, append = TRUE, sep = "")
  invisible(entry)
}
