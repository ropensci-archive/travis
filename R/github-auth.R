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
