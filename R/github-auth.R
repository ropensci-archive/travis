auth_github_ <- function(...) {
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Authenticating to GitHub."
  )
  cache <- FALSE

  scopes <- c(...)
  app <- httr::oauth_app("github",
                         key = "a8495eadc51e6c64d598",
                         secret = "8de4a03c5f978b77c3bd021b7c9528b794301168")
  token <- httr::oauth2.0_token(
    httr::oauth_endpoints("github"), app,
    scope = scopes, cache = cache
  )
  cli::cat_bullet(bullet = "tick", bullet_col = "green",
    "Authentication successful.")

  token
}

#' Authenticate with GitHub
#'
#' Creates an OAuth token for the requested scopes.
#' For each combination of scopes, the token will be obtained only once in each
#' R session, but it will never be cached on the file system.
#' In most scenarios, this function will be called implicitly by other functions.
#'
#' @param ... `[character]`\cr
#'   One or more OAuth scopes for GitHub.
#'
#' @export
auth_github <- memoise::memoise(auth_github_)
