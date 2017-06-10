url_message <- function(..., url) {
  message(format_url_msg(..., url = url))
  open_browser_window(url)
}

url_stop <- function(..., url) {
  open_browser_window(url)
  stopc(format_url_msg(..., url = url))
}

format_url_msg <- function(..., url) {
  paste0(..., ". Please visit\n  ", url, get_browser_window_text())
}

stopc <- function(...) {
  stop(..., call. = FALSE, domain = NA)
}

warningc <- function(...) {
  warning(..., call. = FALSE, domain = NA)
}

get_browser_window_text <- function() {
  if (will_open_browser_window()) {
    "\nA browser window will be opened."
  } else {
    ""
  }
}

open_browser_window <- function(url) {
  if (will_open_browser_window()) {
    utils::browseURL(url)
  }
}

will_open_browser_window <- function() {
  interactive()
}

check_status <- function(req, message, quiet = TRUE, accept_code = integer()) {
  if (!(httr::status_code(req) %in% accept_code)) {
    httr::stop_for_status(req, remove_brackets(message))
  }
  if (!quiet) message("Finished ", keep_brackets(message), ".")
}

remove_brackets <- function(message) {
  # strip (, unless there is space in between
  message <- gsub("\\{([^\\} ]+)\\}", "\\1", message, perl = TRUE)
  # remove [ and its content, unless there is space in between
  message <- gsub("\\[[^\\] ]+\\]\\s*", "", message, perl = TRUE)

  message
}

keep_brackets <- function(message) {
  # strip [, unless there is space in between
  message <- gsub("\\[([^\\] ]+)\\]", "\\1", message, perl = TRUE)
  # remove ( and its content, unless there is space in between
  message <- gsub("\\{[^\\} ]+\\}", "", message, perl = TRUE)

  message
}
