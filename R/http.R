#' @title Travis CI HTTP Requests
#'
#' @description This is the workhorse function for executing API requests for
#'   Travis CI.
#'
#' @import httr
#' @importFrom jsonlite fromJSON
#'
#' @details This is mostly an internal function for executing API requests. In
#'   almost all cases, users do not need to access this directly.
#'
#' @param verb A character string containing an HTTP verb, defaulting to `GET`.
#' @param path A character string with the API endpoint (should begin with a
#'   slash).
#' @param query A list specifying any query string arguments to pass to the API.
#'   This is used to pass the API token.
#' @param body A named list or character string of what should be passed in the
#'   request. Corresponds to the "-d" argument of the `curl` command.
#' @template endpoint
#' @param encode Encoding format. See [httr::POST].
#'
#' @return The JSON response, or the relevant error.
#'
#' @export
travis <- function(verb = "GET",
                   path = "",
                   query = list(),
                   body = "",
                   endpoint = ".org",
                   encode = "json") {
  url <- sprintf("https://api.travis-ci%s%s", endpoint, path)

  auth_travis(endpoint = endpoint)
  api_token <- read_token(endpoint = endpoint)
  # set user agent
  ua <- user_agent("http://github.com/ropenscilabs/travis")

  resp <- VERB(
    verb = verb, url = url,
    add_headers(
      Authorization = sprintf("token %s", api_token),
      "Travis-API-Version" = 3
    ),
    query = query, encode = encode, ua, accept_json(),
    content_type_json()
  )

  # for travis_delete_var()
  if (http_type(resp) == "application/octet-stream") {
    return(resp)
  }
  if (http_type(resp) == "text/plain") {
    return(resp)
  }

  parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

  # catch specific errors
  if (any(grepl("error_type", names(parsed))) && parsed$error_type == "job_already_running") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Job already running.")
    stop()
  } else if (any(grepl("error_type", names(parsed))) && parsed$error_type == "job_not_cancelable") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Job is not running, cannot cancel.")
    stop()
  } else if (any(grepl("error_type", names(parsed))) && parsed$error_type == "log_already_removed") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Log has already been removed.")
    stop()
  } else if (any(grepl("error_type", names(parsed))) && parsed$error_type == "not_found") {
    cli::cat_bullet(bullet = "cross", bullet_col = "red", "Could not find env var. This might be due to insufficient access rights.")
    stop()
  }

  if (status_code(resp) != 200 && status_code(resp) != 201 && status_code(resp) != 202) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>",
        status_code(resp),
        parsed[["@type"]],
        parsed$content
      ),
      call. = FALSE
    )
  }

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "travis_api"
  )
}
