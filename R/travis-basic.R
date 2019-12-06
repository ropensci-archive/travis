#' @title Get repository information from Travis CI
#'
#' @description
#' Return repository information, in particular the repository ID.
#'
#' @import httr
#'
#' @details
#' `travis_repo_info()` queries the `"/repos/:repo"` API.
#'
#' @param repo `[string|numeric]`\cr
#'   The GitHub repo slug, by default obtained through [github_repo()].
#'   Alternatively, the Travis CI repo ID, e.g. obtained through
#'   `travis_repo_id()`.
#' @template endpoint
#' @seealso [Travis CI API documentation](https://docs.travis-ci.com/api)
#'
#' @family Travis CI functions
#'
#' @export
travis_repo_info <- function(repo = github_repo(), endpoint = get_endpoint()) {
  req <- travis(
    path = sprintf("/repo/%s", encode_slug(repo)),
    endpoint = endpoint
  )

  new_travis_repo(content(req$response))
}

#' @export
#' @rdname travis_repo_info
travis_has_repo <- function(repo = github_repo(), endpoint = get_endpoint()) {
  req <- travis(
    path = sprintf("/repo/%s", encode_slug(repo)),
    endpoint = endpoint
  )
  status <- status_code(req$response)
  if (status == 404) {
    return(FALSE)
  }
  TRUE
}

#' @description
#' `travis_repo_id()` returns the repo ID obtained from `travis_repo_info()`.
#'
#' @export
#' @rdname travis_repo_info
travis_repo_id <- function(repo = github_repo()) {
  travis_repo_info(repo = repo)$id
}

#' @description
#' `travis_repo_settings()` returns build settings
#'
#' @export
#' @rdname travis_repo_info
travis_repo_settings <- function(repo = github_repo()) {
  req <- travis(path = sprintf("/repo/%s/settings", encode_slug(repo)))

  stop_for_status(
    req$response,
    sprintf("get repo settings on %s from Travis", repo)
  )
  new_travis_settings(content(req$response))
}

new_travis_settings <- function(x) {
  stopifnot(x[["@type"]] == "settings")
  new_travis_collection(
    lapply(x[["settings"]], new_travis_setting),
    travis_attr(x),
    "settings"
  )
}

new_travis_setting <- function(x) {
  stopifnot(x[["@type"]] == "setting")
  new_travis_object(x, "setting")
}
