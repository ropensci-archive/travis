#' Set the GITHUB_PAT variable on Travis
#'
#' Assigns a GitHub PAT to the `GITHUB_PAT` private variable on Travis CI
#' via [travis_set_var()],
#' among others this works around GitHub API rate limitations.
#' By default, the PAT is obtained from [github_create_pat()].
#'
#' @param pat `[string]`\cr
#'   If set, avoids calling `github_create_pat()`
#' @inheritParams travis_repo_info
#' @inheritParams github_create_repo
#'
#' @family Travis CI functions
#'
#' @export
travis_set_pat <- function(pat = NULL,
                           repo = github_repo(),
                           token = auth_travis(),
                           quiet = FALSE) {
  if (is.null(pat)) {
    pat <- github_create_pat(repo = repo)
  }
  travis_set_var("GITHUB_PAT", pat,
    public = FALSE,
    repo = repo,
    token = token, quiet = quiet
  )
}
