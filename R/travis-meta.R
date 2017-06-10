#' @export
travis_accounts <- function(token = travis_token()) {
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'), token = token)
  httr::stop_for_status(req, paste("list accounts"))
  httr::content(req)[[1L]]
}

#' @export
travis_repositories <- function(slug = NULL, search = NULL, token = travis_token()) {
  req <- TRAVIS_GET("/repos", query = list(slug = slug, search = search), token = token)
  httr::stop_for_status(req, paste("list repositories"))
  httr::content(req)[[1L]]
}

#' @export
travis_user <- function(token = travis_token()) {
  req <- TRAVIS_GET("/users/", token = token)
  httr::stop_for_status(req, paste("get current user information"))
  httr::content(req)[[1L]]
}

#' @export
#' @rdname travis-package
travis_repo_info <- function(repo = github_repo(),
                             token = travis_token(repo)) {
  req <- TRAVIS_GET(sprintf("/repos/%s", repo), token = token)
  httr::stop_for_status(req, sprintf("get repo info on %s from Travis", repo))
  httr::content(req)[[1L]]
}

#' @export
#' @rdname travis-package
travis_repo_id <- function(repo = github_repo(), token = travis_token(repo), ...) {
  travis_repo_info(repo = repo, ..., token = token)$id
}

#' @export
#' @rdname travis-package
uses_travis <- function(repo = github_repo(), token = travis_token(repo),
                        repo_id = travis_repo_id(repo, token = token)) {
  req <- TRAVIS_GET(sprintf("/repos/%s", repo_id), token = token)
  httr::stop_for_status(
    req, sprintf(
      "%s repo %s on travis",
      ifelse(active, "activate", "deactivate"), repo_id))
  httr::content(req)$repo$active
}

#' @export
#' @rdname travis-package
travis_enable <- function(active = TRUE, repo = github_repo(),
                          token = travis_token(repo), repo_id = travis_repo_id(repo, token = token)) {
  req <- TRAVIS_PUT(sprintf("/hooks"),
                    body = list(hook = list(id = repo_id, active = active)),
                    token = token)
  httr::stop_for_status(
    req, sprintf(
      "%s repo %s on travis",
      ifelse(active, "activate", "deactivate"), repo_id))
  invisible(httr::content(req)[[1]])
}
