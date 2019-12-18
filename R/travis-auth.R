#' Authenticate to Travis
#' @description
#'   A Travis API Key is needed to interact with the Travis API.
#'   `browse_travis_token()` opens a browser window for the respective Travis
#'   endpoint. On this site, you can copy your personal API key and then follow
#'   the instructions of the console output or the ones shown below.
#' @section Store API Key:
#'   1. Copy the token from the browser window which just opened. You can use
#'   `edit_travis_config()` to open `~/.travis/config.yml` easily.
#'   2. The token should be stored with the following structure
#'
#'      ```
#'      endpoints:
#'       https://api.travis-ci.<endpoint>/:
#'         access_token: <token>
#'      ```
#'      with `<endpoint>` being either 'com' or 'org'.
#' @template endpoint
#' @export
#'
browse_travis_token <- function(endpoint = get_endpoint()) {

  check_endpoint()

  cli::cli_alert("Querying API token...")
  cli::cli_text("Opening URL {.url {
    sprintf('https://travis-ci%s/account/preferences', endpoint)}}.")
  utils::browseURL(sprintf(
    "https://travis-ci%s/account/preferences",
    endpoint
  ))
  cli::cli_alert("Call {.code travis::edit_travis_config()} to open
                 {.file ~/.travis/config.yml}.")
  cli::cli_alert("Store the API token with a line like:")
  cli::cli_code(
    "endpoints:",
    "  https://api.travis-ci.<endpoint>/:",
    "    access_token: <token>",
    language = "yml"
  )
  cli::cli_text("with <endpoint> being either 'com' or 'org'.")
  return(invisible(TRUE))
}

#' @title Open Travis Configuration file
#' @importFrom usethis edit_file
#' @description
#'   Opens `~/.travis/config.yml`.
#' @export
edit_travis_config <- function() {
  edit_file("~/.travis/config.yml")
}

travis_check_api_key <- function(endpoint = get_endpoint()) {

  if (!file.exists("~/.travis/config.yml")) {

    cli::cli_alert_danger("To interact with the Travis CI API, an API token is
        required. Please call {.fun browse_travis_token} first.",
      wrap = TRUE
    )
    stopc("Travis API key missing.")
  } else {
    yml <- readLines("~/.travis/config.yml")
    if (!any(grepl(sprintf("api.travis-ci%s/:", endpoint), yml))) {
      cli::cli_alert_danger("No Travis API key for endpoint '{endpoint}'
        found. Please call {.code browse_travis_token(endpoint =
        '{endpoint}')} first.", wrap = TRUE)
      stopc("Travis API key missing.")
    }
  }
}

is_token <- function(token) {
  grepl("^[-a-zA-Z0-9_]{18}", token)
}

read_token <- function(endpoint) {
  yml <- readLines("~/.travis/config.yml")
  endpoint_line <- which(grepl(sprintf("api.travis.ci%s", endpoint), yml))
  token <- yml[endpoint_line + 1]
  token <- strsplit(token, " ")[[1]][6]
  return(token)
}
