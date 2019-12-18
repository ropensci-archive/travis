#' Travis CI client package for R
#'
#' Use [github_repo()] to get the name of the current repository
#' as determined from the `origin` remote.
#' The following functions simplify integrating R package testing and deployment
#' with GitHub and Travis CI:
#' - [travis_enable()] enables Travis CI for your repository,
#' - [use_travis_deploy()] installs a public deploy key on GitHub and the
#'   corresponding private key on Travis CI to simplify deployments to GitHub
#'   from Travis CI.
#' @docType package
#' @name travis-package
NULL

#' Travis CI HTTP Requests
#'
#' This is the workhorse function for executing API requests for
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
#' @export
travis <- function(verb = "GET",
                   path = "",
                   query = list(),
                   body = "",
                   endpoint = get_endpoint(),
                   encode = "json") {

  # check for endpoint env var R_TRAVIS or R_TRAVIS_ORG or R_TRAVIS_COM
  check_endpoint()

  # check for api key
  api_token <- travis_check_api_key(endpoint = endpoint)

  url <- endpoint_url(endpoint, path)

  # set user agent
  ua <- user_agent("http://github.com/ropenscilabs/travis")

  resp <- VERB(
    verb = verb, url = url, body = body,
    add_headers(
      Authorization = sprintf("token %s", api_token),
      "Travis-API-Version" = 3
    ),
    query = query, encode = encode, ua, accept_json()
  )

  # for travis_delete_var()
  if (http_type(resp) == "application/octet-stream") {
    return(resp)
  }
  # for travis_get_log
  if (http_type(resp) == "text/plain") {
    return(resp)
  }

  # parse response into readable object
  parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"),
    simplifyVector = FALSE
  )

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "travis_api"
  )
}
