auth_travis_ <- function() {
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Authenticating to GitHub."
  )
    # Do not allow caching this token, it needs to be fresh
    gh_token <- auth_github_(
      "read:org", "user:email", "repo_deployment", "repo:status",
      "read:repo_hook", "write:repo_hook"
    )
  auth_travis_data <- list(
    "github_token" = gh_token$credentials$access_token
  )
  auth_travis <- TRAVIS_POST(
    url = "/auth/github",
    body = auth_travis_data,
    httr::user_agent("Travis/1.0"),
    token = NULL
  )
  httr::stop_for_status(auth_travis, "authenticate with travis")
  httr::content(auth_travis)$access_token
}

#' Authenticate with Travis CI
#'
#' @description
#' Authenticates with Travis using your Github account. Returns an access token.
#' The token will be obtained only once in each
#' R session, but it will never be cached on the file system.
#' In most scenarios, these functions will be called implicitly by other functions.
#'
#' `auth_travis()` only performs the authentication with Travis CI.
#'
#' @export
auth_travis <- memoise::memoise(auth_travis_)

travis_token_ <- function(repo = NULL) {
  token <- auth_travis()
  if (!is.null(repo)) {
    if (!travis_has_repo(repo, token)) {
      travis_sync(token = token)
      if (!travis_has_repo(repo, token)) {
        review_travis_app_permission(repo)
      }
    }
  }
  token
}

review_travis_app_permission <- function(repo) {
  url_stop(
    "You may need to retry in a few seconds. ",
    "If your repo ", repo, " belongs to an organization, you may need to allow Travis access to that organization",
    url = "https://github.com/settings/connections/applications/f244293c729d5066cf27"
  )
}

#' @description
#' `travis_token()` authenticates and checks if the repository is known to
#' Travis CI. If not, a GitHub sync via [travis_sync()] is performed.
#'
#' @param repo `[string]`\cr
#'   The GitHub repo slug in the format "<user|org>/<repo>", if `NULL` no sync
#'   is performed.
#'
#' @export
#' @rdname auth_travis
travis_token <- memoise::memoise(travis_token_)
