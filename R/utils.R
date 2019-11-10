url_message <- function(..., url) {
  message(format_url_msg(..., ". ", url = url))
  open_browser_window(url)
}

url_stop <- function(..., url) {
  open_browser_window(url)
  stopc(format_url_msg(..., ". ", url = url))
}

format_url_msg <- function(..., url) {
  paste0(..., "Please visit\n  ", url, get_browser_window_text())
}

stopc <- function(...) {
  stop(..., call. = FALSE, domain = NA)
}

warningc <- function(...) {
  warning(..., call. = FALSE, domain = NA)
}

get_browser_window_text <- function() {
  if (will_open_browser_window()) {
    "\n  A browser window will be opened."
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
  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    "Finished checking status."
  )
}

remove_brackets <- function(message) {
  # strip {, unless there is space in between
  message <- gsub("\\{([^\\} ]*)\\}", "\\1", message, perl = TRUE)
  # remove [ and its content, unless there is space in between
  message <- gsub("\\[[^\\] ]*\\]", "", message, perl = TRUE)

  message
}

keep_brackets <- function(message) {
  # strip [, unless there is space in between
  message <- gsub("\\[([^\\] ]*)\\]", "\\1", message, perl = TRUE)
  # remove ( and its content, unless there is space in between
  message <- gsub("\\{[^\\} ]*\\}", "", message, perl = TRUE)

  message
}

catch_error = function(object) {
  if (object$error_type == "job_already_running") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Job already running.")
    stop()
  } else if (object$error_type == "job_not_cancelable") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Job is not running, cannot cancel.")
    stop()
  } else if (object$error_type == "log_already_removed") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Log has already been removed.")
    stop()
  } else if (object$error_type == "not_found") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Could not find env var. This might be due to insufficient access rights.")
    stop()
  }
}

endpoint <- function(ednpoint, path) {
  return(sprintf("https://api.travis-ci%s%s", endpoint, path))
}
