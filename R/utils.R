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
        not set by user. Defaulting to '.com' endpoint.
        If supplied, the {.arg endpoint} argument in
        any {.fun travis_*} function will take precedence.
        (This message is displayed once per session.)")
      Sys.setenv("R_TRAVIS" = ".com")
    }
    # for an empty line before any log output appears
    cli::cli_par()
    cli::cli_end()
  }
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}

get_api_token <- function(endpoint) {

  # one can set the API key directly via an env var. This is needed on CI
  # systems to be able to have the API key available during builds

  if (endpoint == ".org" && Sys.getenv("R_TRAVIS_ORG") == "") {
    api_token <- read_token(endpoint = endpoint)
  } else if (endpoint == ".com" && Sys.getenv("R_TRAVIS_COM") == "") {
    api_token <- read_token(endpoint = endpoint)
  } else {
    if (endpoint == ".org") {
      api_token <- Sys.getenv("R_TRAVIS_ORG")
    } else {
      api_token <- Sys.getenv("R_TRAVIS_COM")
    }
  }
  return(api_token)
}
