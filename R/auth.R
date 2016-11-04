# GitHub ------------------------------------------------------------------


auth_github_ <- function(cache = NULL, scopes = NULL) {
  message("Authenticating with GitHub")
  if (is.null(cache)) {
    cache <- getOption("httr_oauth_cache")
  }

  if (is.null(scopes)) {
    scopes <- c("repo", "read:org", "user:email", "write:repo_hook")
  }
  app <- httr::oauth_app("github",
                         key = "4bca480fa14e7fb785a1",
                         secret = "70bb4da7bab3be6828808dd6ba37d19370b042d5")
  httr::oauth2.0_token(httr::oauth_endpoints("github"), app, scope = scopes, cache = cache)
}

#' @export
auth_github <- memoise::memoise(auth_github_)

# Travis ------------------------------------------------------------------


travis_token_ <- function(repo = NULL) {
  token <- auth_travis()
  if (!identical(travis_user(token)$correct_scopes, TRUE)) {
    url_stop("Please sign up with Travis using your GitHub credentials",
             url = "https://travis-ci.org")
  }
  if (!is.null(repo)) {
    if (!has_repo(repo, token)) {
      travis_sync(token = token)
      if (!has_repo(repo, token)) {
        review_travis_app_permission(repo)
      }
    }
  }
  token
}

has_repo <- function(repo, token) {
  repos <- travis_repositories(slug = repo, token = token)
  length(repos) > 0
}

review_travis_app_permission <- function(org) {
  url_stop("You may need to retry in a few seconds, or allow Travis access to your organization ", org,
           url = "https://github.com/settings/connections/applications/f244293c729d5066cf27")
}

#' Authenticate with Travis
#'
#' Authenticate with Travis using your Github account. Returns an access token.
#'
#' @export
travis_token <- memoise::memoise(travis_token_)

auth_travis_ <- function(gtoken = NULL) {
  message("Authenticating with Travis")
  if (is.null(gtoken)) {
    gtoken <- auth_github_(
      cache = FALSE,
      scopes = c("read:org", "user:email", "repo_deployment", "repo:status", "read:repo_hook", "write:repo_hook"))
  }
  auth_travis_data <- list(
    "github_token" = gtoken$credentials$access_token
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

#' @export
auth_travis <- memoise::memoise(auth_travis_)
