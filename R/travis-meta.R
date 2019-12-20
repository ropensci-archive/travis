#' @title Retrieve meta information from Travis CI
#'
#' @description
#' Return repositories and user information.
#'
#' @details
#' `travis_repositories()` queries the `"/repos"` API.
#'
#' @inheritParams travis_repo_info
#' @template quiet
#'
#' @seealso [Travis CI API documentation](https://developer.travis-ci.com/)
#'
#' @family Travis CI functions
#'
#' @export
travis_repos <- function(endpoint = get_endpoint(),
                         quiet = FALSE,
                         ...) {

  req <- travis(path = "/repos", endpoint = endpoint, ...)

  if (!quiet) {
    cli::cli_alert("Querying information about repos.")
  }
  new_travis_repos(httr::content(req$response))
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
#' @template quiet
#' @template ellipsis
#' @export
#'
#' @rdname travis_repos
travis_user <- function(quiet = FALSE, ...) {

  req <- travis(path = "/user", ...)

  stop_for_status(req$response)

  if (!quiet) {
    cli::cli_alert_success("Queried information about user.")
  }
  new_travis_user(httr::content(req$response))
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
