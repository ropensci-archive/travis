#' Activate Travis CI
#'
#' @description
#' Activating Travis CI, and querying activity status.
#'
#' `travis_enable()` activates or deactivates Travis CI for a repo.
#'
#' @param active `[flag]`\cr
#'   Set to `FALSE` to deactivate instead of activating.
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#'
#' @export
travis_enable <- function(active = TRUE, repo = github_repo()) {
  if (active) {
    activate <- "activate"
  } else {
    activate <- "deactivate"
  }

  req = travisHTTP(verb = "POST", path = sprintf("/repo/%s/%s", encode_slug(repo), activate))

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "%s repo %s on Travis CI",
        ifelse(active, "Activat[ing]{e}", "Deactivat[ing]{e}"), repo
      )
    )
    invisible(new_travis_repo(content(req$response)))
  }
}

#' @description
#' `travis_is_enabled()` returns if Travis CI is active for a repo.
#' @export
#' @rdname travis_enable
travis_is_enabled <- function(repo = github_repo()) {
  info <- travis_repo_info(repo = repo)
  info[["active"]]
}
