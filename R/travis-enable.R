#' @export
#' @rdname travis-package
uses_travis <- function(repo = github_repo(), token = travis_token(repo),
                        repo_id = travis_repo_id(repo = repo, token = token)) {
  req <- TRAVIS_GET(sprintf("/repos/%s", repo_id), token = token)
  httr::stop_for_status(
    req, sprintf("check status for repo %s (id: %s) on Travis CI", repo, repo_id))
  httr::content(req)$repo$active
}

#' @export
#' @rdname travis-package
travis_enable <- function(active = TRUE, repo = github_repo(),
                          token = travis_token(repo = repo),
                          repo_id = travis_repo_id(repo = repo, token = token),
                          quiet = FALSE) {
  req <- TRAVIS_PUT(sprintf("/hooks"),
                    body = list(hook = list(id = repo_id, active = active)),
                    token = token)
  check_status(
    req,
    sprintf(
      "%s repo %s (id: %s) on Travis CI",
      ifelse(active, "activat[ing]{e}", "deactivat[ing]{e}"), repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}
