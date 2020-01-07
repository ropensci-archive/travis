#' Authenticate to Travis
#' @description
#'   A Travis API Key is needed to interact with the Travis API.
#'   `browse_travis_token()` opens a browser window for the respective Travis
#'   endpoint. On this site, you can copy your personal API key and then follow
#'   the instructions of the console output or the ones shown below.
#' @section Store API Key:
#'
#'   The `travis` package supports two ways of storing the Travis API key(s):
#'
#'   - via env vars `R_TRAVIS_ORG` and `R_TRAVIS_COM`
#'   - via `~/.travis/config.yml`
#'
#'   The latter should already be present if you already used the `travis` CLI
#'   tool at some point in the past. If not, its up to your preference which
#'   approach to use.
#'
#'   The following instructions should help to set up `~/.travis/config.yml`
#'   correctly:
#'   1. Copy the token from the browser window which just opened. You can use
#'   `edit_travis_config()` to open `~/.travis/config.yml`.
#'   2. The token should be stored using the following structure
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
  cli::cli_text("Opening URL {.url
    https://travis-ci{endpoint}/account/preferences}.")
  utils::browseURL(sprintf(
    "https://travis-ci%s/account/preferences",
    endpoint
  ))
  cli::cli_alert("Call {.fun travis::edit_travis_config} to open
    {.file ~/.travis/config.yml} or {.fun edit_r_environ} to open
    {.file ~/.Renviron}, depending on how
    you want to store the API key. See {.code ?travis::browse_travis_token()} for
    details.", wrap = TRUE)
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

# check if API key is stored in ~/.travis/config.yml
travis_check_api_key <- function(endpoint = get_endpoint()) {

  if (endpoint == ".org" && !Sys.getenv("R_TRAVIS_ORG") == "") {
    return(Sys.getenv("R_TRAVIS_ORG"))
  } else if (endpoint == ".com" && !Sys.getenv("R_TRAVIS_COM") == "") {
    return(Sys.getenv("R_TRAVIS_COM"))
  } else {

    # some checks for ~/.travis/config.yml

    if (!file.exists("~/.travis/config.yml")) {

      cli::cli_alert_danger("To interact with the Travis CI API, an API token is
        required. Please call {.fun browse_travis_token} first.
        Alternatively, set the API key via env vars {.var R_TRAVIS_ORG} or
        {.var R_TRAVIS_COM}.", wrap = TRUE)
      stopc("Travis API key missing.")
    } else {
      yml <- readLines("~/.travis/config.yml")
      if (!any(grepl(sprintf("api.travis-ci%s/:", endpoint), yml))) {
        cli::cli_alert_danger("No Travis API key for endpoint '{endpoint}'
        found. Please call {.code travis::browse_travis_token(endpoint =
        '{endpoint}')} first.", wrap = TRUE)
        stopc("Travis API key missing.")
      }
    }
    return(read_token(endpoint = endpoint))
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
