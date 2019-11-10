#' @title Retrieve meta information from Travis CI
#'
#' @description
#' Return repositories and user information.
#'
#' @details
#' `travis_repositories()` queries the `"/repos"` API.
#'
#' @inheritParams travis_repo_info
#'
#' @seealso [Travis CI API documentation](https://developer.travis-ci.com/)
#'
#' @family Travis CI functions
#'
#' @export
travis_repos <- function(endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint <- Sys.getenv("R_TRAVIS", unset = "ask")
  }

  req <- travisHTTP(path = "/repos", endpoint = endpoint)

  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    "Querying information about repos."
  )
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
#' @export
#'
#' @rdname travis_repos
travis_user <- function() {

  req <- travisHTTP(path = "/user")

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      "Querying information about user."
    )
    new_travis_user(httr::content(req$response))
  }
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
