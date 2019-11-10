#' Authenticate to Travis
#' @description
#'   Authenticates to Travis and returns a Travis API token
#' @template endpoint
#' @export
#'
auth_travis <- function(endpoint = ".org") {
  yml <- tryCatch(
    {
      readLines("~/.travis/config.yml")
    },
    warning = function(cond) {
      cli::cat_bullet(
        bullet = "pointer", bullet_col = "yellow",
        c(
          "To interact with the Travis CI API, an API token is required.",
          "This is a one-time procedure. The token will be stored in your home directory in the '.travis' directory."
        )
      )
    }
  )
  # create api token if none is found but config file exists
  if (!any(grepl(sprintf("api.travis-ci%s/:", endpoint), yml))) {
    message("Querying API token...")
    utils::browseURL(sprintf("https://travis-ci%s/account/preferences", endpoint))
    wait_for_clipboard_token(endpoint = endpoint)
    return(invisible(TRUE))
  }
}

wait_for_clipboard_token <- function(endpoint) {
  cli::cat_bullet(
    bullet = "info", bullet_col = "yellow",
    " Waiting for API token to appear on the clipboard."
  )
  Sys.sleep(3)

  repeat {
    token <- readline("Please paste the API token to the console.\n")
    if (is_token(token)) break
    Sys.sleep(0.1)
  }
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Detected token, clearing clipboard."
  )
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
  has_conf <- tryCatch(
    {
      file.exists("~/.travis/config.yml")
    },
    warning = function(cond) {
      cli::cat_bullet(
        bullet = "pointer", bullet_col = "yellow",
        c(
          "Existing token detected. Appending new API token."
        )
      )
    }
  )

  if (has_conf) {
    endpoint_line <- which(grepl(sprintf("endpoints", endpoint), readLines("~/.travis/config.yml")))
    yml <- readLines("~/.travis/config.yml")
    yml[endpoint_line] <- sprintf(
      "endpoints:\n  https://api.travis-ci%s/:\n    access_token: %s",
      endpoint, token
    )
    writeLines(yml, "~/.travis/config.yml")

  } else {
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
