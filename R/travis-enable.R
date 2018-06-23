#' Activate Travis CI
#'
#' @description
#' Activating Travis CI, and querying activity status.
#'
#' `travis_enable()` activates or deactivates Travis CI for a repo.
#'
#' @param active `[flag]`\cr
#'   Set to `FALSE` to deactivate instead of activating.
#' @inheritParams travis_set_pat
#'
#' @export
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

#' @description
#' `uses_travis()` returns if Travis CI is active for a repo.
#' @export
#' @rdname travis_enable
travis_is_enabled <- function(repo = github_repo(), token = travis_token(repo)) {
  info <- travis_repo_info(repo = repo, token = token)
  info[["active"]]
}
