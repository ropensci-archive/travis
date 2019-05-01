#' Get repository information from Travis CI
#'
#' @description
#' Return repository information, in particular the repository ID.
#'
#' `travis_repo_info()` queries the "/repos/:repo" API.
#'
#' @param repo `[string|numeric]`\cr
#'   The GitHub repo slug, by default obtained through [github_repo()].
#'   Alternatively, the Travis CI repo ID, e.g. obtained through `travis_repo_id()`.
#' @param token `[Token2.0]`\cr
#'   A Travis CI token obtained from [travis_token()] or [auth_travis()].
#'
#' @seealso [Travis CI API documentation](https://docs.travis-ci.com/api)
#'
#' @family Travis CI functions
#'
#' @export
travis_repo_info <- function(repo = github_repo(),
                             token = travis_token(repo)) {
  req <- TRAVIS_GET3(sprintf("/repo/%s", encode_slug(repo)), token = token)
  httr::stop_for_status(req, sprintf("get repo info on %s from Travis", repo))
  new_travis_repo(httr::content(req))
}

#' @export
#' @rdname travis_repo_info
travis_has_repo <- function(repo = github_repo(), token = travis_token()) {
  req <- TRAVIS_GET3(sprintf("/repo/%s", encode_slug(repo)), token = token)
  status <- httr::status_code(req)
  if (status == 404) {
    return(FALSE)
  }
  httr::stop_for_status(req, paste("try to access repository"))
  TRUE
}

#' @description
#' `travis_repo_id()` returns the repo ID obtained from `travis_repo_info()`.
#'
#' @export
#' @rdname travis_repo_info
travis_repo_id <- function(repo = github_repo(), token = travis_token(repo)) {
  travis_repo_info(repo = repo, token = token)$id
}

#' @description
#' `travis_repo_settings()` returns build settings
#'
#' @export
#' @rdname travis_repo_info
travis_repo_settings <- function(repo = github_repo(), token = travis_token(repo)) {
  req <- TRAVIS_GET3(sprintf("/repo/%s/settings", encode_slug(repo)), token = token)
  httr::stop_for_status(req, sprintf("get repo settings on %s from Travis", repo))
  new_travis_settings(httr::content(req))
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
