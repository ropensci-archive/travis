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
  if (!quiet) {
    cli::cli_alert_success("Finished checking status.")
  }
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

catch_error <- function(object) {
  if (object$error_type == "job_already_running") {
    cli::cli_alert_danger("Job already running.")
    stop()
  } else if (object$error_type == "job_not_cancelable") {
    cli::cli_alert_danger("Job is not running, cannot cancel.")
    stop()
  } else if (object$error_type == "log_already_removed") {
    cli::cli_alert_danger("Log has already been removed.")
    stop()
  } else if (object$error_type == "not_found") {
    cli::cli_alert_danger("Could not find env var.
                          This might be due to insufficient access rights.",
      wrap = TRUE
    )
    stop()
  }
}

get_endpoint <- function() {
  endpoint <- Sys.getenv("R_TRAVIS")
  return(endpoint)
}

endpoint_url <- function(endpoint, path) {
  return(sprintf("https://api.travis-ci%s%s", endpoint, path))
}

check_endpoint <- function() {

  if (Sys.getenv("R_TRAVIS_CHECKED") == "") {

    Sys.setenv("R_TRAVIS_CHECKED" = "true")

    if (Sys.getenv("R_TRAVIS") != "") {
      cli::cli_text("{.pkg travis}: Using Travis endpoint
        {.code {Sys.getenv('R_TRAVIS')}} set via env var {.envvar R_TRAVIS}.
        If supplied, the {.arg endpoint} argument in
        any {.fun travis_*} function will take precedence.
        (This message is displayed once per session.)")
    } else {
      cli::cli_text("{.pkg travis}: Env var {.envvar R_TRAVIS}
        not set by user. Defaulting to '.org' endpoint.
        If supplied, the {.arg endpoint} argument in
        any {.fun travis_*} function will take precedence.
        (This message is displayed once per session.)")
      Sys.setenv("R_TRAVIS" = ".org")
    }
    # for an empty line before any log output appears
    cli::cli_par()
    cli::cli_end()
  }
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}
