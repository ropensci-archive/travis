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
                          token = travis_auth(),
                          quiet = FALSE) {
  if (active) {
    activate <- "activate"
  } else {
    activate <- "deactivate"
  }

  req <- TRAVIS_POST3(sprintf("/repo/%s/%s", encode_slug(repo), activate),
    token = token
  )
  check_status(
    req,
    sprintf(
      "%s repo %s on Travis CI",
      ifelse(active, "activat[ing]{e}", "deactivat[ing]{e}"), repo
    ),
    quiet
  )
  invisible(new_travis_repo(httr::content(req)))
}

#' @description
#' `travis_is_enabled()` returns if Travis CI is active for a repo.
#' @export
#' @rdname travis_enable
travis_is_enabled <- function(repo = github_repo(), token = auth_travis()) {
  info <- travis_repo_info(repo = repo, token = token)
  info[["active"]]
}
