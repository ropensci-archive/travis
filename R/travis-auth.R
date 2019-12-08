#' Authenticate to Travis
#' @description
#'   Authenticates to Travis and asks to create an API key if none exists.
#' @template endpoint
#' @export
#'
auth_travis <- function(endpoint = get_endpoint()) {
  yml <- tryCatch(
    {
      readLines("~/.travis/config.yml")
    },
    warning = function(cond) {
      cli::cli_alert_info("To interact with the Travis CI API, an API token is
        required. This is a one-time procedure. The token will be stored in
        your home directory in the '.travis' directory.", wrap = TRUE)
    }
  )
  # create api token if none is found but config file exists
  if (!any(grepl(sprintf("api.travis-ci%s/:", endpoint), yml))) {
    message("Querying API token...")
    url <- sprintf("https://travis-ci%s/account/preferences", endpoint)
    cli::cli_text("Opening {.url {url}}")
    utils::browseURL(sprintf("https://travis-ci%s/account/preferences", endpoint))
    wait_for_clipboard_token(endpoint = endpoint)
    return(invisible(TRUE))
  }
}

wait_for_clipboard_token <- function(endpoint) {
  cli::cli_alert_info(
    "Waiting for API token to appear on the clipboard."
  )
  Sys.sleep(3)

  repeat {
    token <- readline("Please paste the API token to the console.\n")
    if (is_token(token)) break
    Sys.sleep(0.1)
  }
  cli::cli_alert("Detected API token. Clearing clipboard.")
  requireNamespace("clipr", quietly = TRUE)
  tryCatch(
    clipr::write_clip(""),
    error = function(e) {
      warning("Error clearing clipboard: ", conditionMessage(e))
    }
  )
  dir.create("~/.travis", showWarnings = FALSE)

  # if there is already a file with the API key of a different endpoint,
  # we need to append only
  has_conf <- file.exists("~/.travis/config.yml")
  if (has_conf) {
    cli::cli_alert_warning(
      "Existing API token detected in {.file ~/.travis/config.yml}.
      Appending new API token ({endpoint}).", wrap = TRUE
    )

    endpoint_line <- which(grepl(sprintf("endpoints", endpoint), readLines("~/.travis/config.yml")))
    yml <- readLines("~/.travis/config.yml")
    yml[endpoint_line] <- sprintf(
      "endpoints:\n  https://api.travis-ci%s/:\n    access_token: %s",
      endpoint, token
    )
    cli::cli_alert("Appending Travis CI API token for endpoint '{endpoint}' to
                   {.file ~/.travis/config.yml}.", wrap = TRUE)
    writeLines(yml, "~/.travis/config.yml")
  } else {
    cli::cli_alert("Storing Travis CI API token for endpoint '{endpoint}' in
                  {.file ~/.travis/config.yml}.", wrap = TRUE)
    writeLines(sprintf(
      "endpoints:\n  https://api.travis-ci%s/:\n    access_token: %s",
      endpoint, token
    ), con = "~/.travis/config.yml")
  }
}

is_token <- function(token) {
  grepl("^[-a-zA-Z0-9_]{18}", token)
}

# travis <- function(endpoint = "") {
#   sprintf("https://api.travis-ci%s", endpoint)
# }

read_token <- function(endpoint) {
  yml <- readLines("~/.travis/config.yml")
  endpoint_line <- which(grepl(sprintf("api.travis.ci%s", endpoint), yml))
  token <- yml[endpoint_line + 1]
  token <- strsplit(token, " ")[[1]][6]
  return(token)
}
