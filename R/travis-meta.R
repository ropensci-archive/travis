#' Retrieve meta information from Travis CI
#'
#' @description
#' Return repositories and user information.
#'
#' `travis_repositories()` queries the "/repos" API.
#'
#' @inheritParams travis_repo_info
#'
#' @seealso [Travis CI API documentation](https://docs.travis-ci.com/api)
#'
#' @family Travis CI functions
#'
#' @export
travis_repos <- function(token = travis_token()) {
  req <- TRAVIS_GET3("/repos", token = token)
  httr::stop_for_status(req, paste("list repositories"))
  new_travis_repos(httr::content(req))
}

new_travis_repos <- function(x) {
  stopifnot(x[["@type"]] == "repositories")
  new_travis_collection(
    lapply(x[["repositories"]], new_travis_repo),
    travis_attr(x),
    "repos"
  )
}

new_travis_repo <- function(x) {
  stopifnot(x[["@type"]] == "repository")
  new_travis_object(x, "repo")
}

#' @export
format.travis_repo <- function(x, ..., short = FALSE) {
  if (short) {
    x[["slug"]]
  } else {
    paste0("Repository ", x[["slug"]], ": ", x[["description"]])
  }
}

#' @description
#' `travis_user()` queries the "/users" API.
#'
#' @export
#'
#' @rdname travis_repos
travis_user <- function(token = travis_token()) {
  req <- TRAVIS_GET3("/user", token = token)
  httr::stop_for_status(req, paste("get current user information"))
  new_travis_user(httr::content(req))
}

new_travis_user <- function(x) {
  stopifnot(x[["@type"]] == "user")
  new_travis_object(x, "user")
}

#' @export
format.travis_user <- function(x, ..., short = FALSE) {
  if (short) {
    paste0(x[["login"]], " (", x[["name"]], ")")
  } else {
    paste0(
      "User (", x[["id"]], "): ", x[["name"]], "\n",
      "Login: ", x[["login"]], "\n"
    )
  }
}
