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
