auth_travis <- function(endpoint = ".org") {
  yml <- tryCatch({
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
    message("Querying API token...")
    utils::browseURL(sprintf("https://travis-ci%s/account/preferences", endpoint))
    wait_for_clipboard_token(endpoint = endpoint)
    return(readLines("~/.travis/config.yml"))
  }
  )

  # create api token if none is found but config file exists
  if (!any(grepl("token", yml))) {
    requireNamespace("utils", quietly = TRUE)
    utils::browseURL(sprintf("https://travis-ci%s/account/preferences", endpoint))
    wait_for_clipboard_token(endpoint = endpoint)
  }
  return(read_token())
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
  dir.create("~/.travis")
  cat(sprintf("endpoints:\n  https://api.travis-ci%s/:\n    access_token: %s",
              endpoint, token), sep = "\n", file = "~/.travis/config.yml")
}

is_token <- function(token) {
  grepl("\\b[a-zA-Z0-9]{18}\\b", token)
}

travis <- function(endpoint = "") {
  sprintf("https://api.travis-ci%s", endpoint)
}

read_token <- function() {
  yml <- readLines("~/.travis/config.yml")
  token <- yml[which(grepl("access_token", yml))]
  token <- strsplit(token, " ")[[1]][6]
  return(token)
}
