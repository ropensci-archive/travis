#' Retrieve meta information from Travis CI
#'
#' @description
#' Return account, repositories, and user information.
#'
#' `travis_accounts()` queries the "/accounts" API.
#'
#' @inheritParams travis_repo_info
#'
#' @seealso [Travis CI API documentation](https://docs.travis-ci.com/api)
#'
#' @family Travis CI functions
#'
#' @export
travis_accounts <- function(token = travis_token()) {
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'), token = token)
  httr::stop_for_status(req, paste("list accounts"))
  httr::content(req)[[1L]]
}

#' @description
#' `travis_repositories()` queries the "/repos" API.
#'
#' @param slug,search `[string]`\cr
#'   Arguments to the API call
#'
#' @export
#'
#' @rdname travis_accounts
travis_repositories <- function(slug = NULL, search = NULL, token = travis_token()) {
  req <- TRAVIS_GET("/repos", query = list(slug = slug, search = search), token = token)
  httr::stop_for_status(req, paste("list repositories"))
  httr::content(req)[[1L]]
}

#' @description
#' `travis_user()` queries the "/users" API.
#'
#' @export
#'
#' @rdname travis_accounts
travis_user <- function(token = travis_token()) {
  req <- TRAVIS_GET("/users/", token = token)
  httr::stop_for_status(req, paste("get current user information"))
  httr::content(req)[[1L]]
}
