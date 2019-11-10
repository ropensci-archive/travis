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

  url <- endpoint(endpoint, path)

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

  # handle special errors without response code
  if (!is.null(parsed$error_type)) {
    catch_error(parsed)
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
