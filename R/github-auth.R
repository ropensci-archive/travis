auth_github_ <- function(...) {
  message("Authenticating with GitHub")
  cache <- FALSE

  scopes <- c(...)
  app <- httr::oauth_app("github",
                         key = "4bca480fa14e7fb785a1",
                         secret = "70bb4da7bab3be6828808dd6ba37d19370b042d5")
  httr::oauth2.0_token(
    httr::oauth_endpoints("github"), app,
    scope = scopes, cache = cache
  )
}

#' Authenticate with GitHub
#'
#' Creates an OAuth token for the requested scopes.
#' For each combination of scopes, the token will be obtained only once in each
#' R session, but it will never be cached on the file system.
#'
#' @param ... `[character]`\cr
#'   One or more OAuth scopes for GitHub.
#'
#' @export
auth_github <- memoise::memoise(auth_github_)
