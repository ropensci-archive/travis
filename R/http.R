#' @title Travis CI HTTP Requests
#'
#' @description This is the workhorse function for executing API requests for
#'   Travis CI.
#'
#' @import httr
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
travisHTTP <- function(verb = "GET",
                       path = "",
                       query = list(),
                       body = "",
                       endpoint = ".org",
                       encode = "json") {
  url <- sprintf("https://api.travis-ci%s%s", endpoint, path)

  auth_travis()
  api_token <- read_token()
  # set user agent
  ua <- user_agent("http://github.com/ropenscilabs/travis")

  if (verb == "GET") {
    resp <- GET(url,
                add_headers(Authorization = sprintf("token %s", api_token),
                            "Travis-API-Version" = "3"),
                query = query, encode = encode, ua, accept_json(),
                content_type_json()
    )
  } else if (verb == "DELETE") {
    resp <- DELETE(url,
                   add_headers(Authentication = sprintf("token %s", api_token),
                               "Travis-API-Version" = "3"),
                   query = query, encode = encode, ua, accept_json(),
                   content_type_json()
    )
  } else if (verb == "POST") {
    resp <- POST(url,
                 add_headers(Authentication = sprintf("token %s", api_token),
                             "Travis-API-Version" = "3"),
                 body = body, query = query, encode = encode, ua,
                 accept_json(), content_type_json()
    )
  }
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

  if (status_code(resp) != 200 && status_code(resp) != 201 && status_code(resp) != 202) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>",
        status_code(resp),
        parsed$message,
        parsed$documentation_url
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
