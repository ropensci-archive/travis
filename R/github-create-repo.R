#' Create a repository on GitHub
#'
#' Creates a GitHub repository for an existing Git repository.
#'
#' @param path `[string]`\cr
#'   The path to the existing Git repository.
#' @param name `[string]`\cr
#'   The name of the new repository on GitHub, default: basename of the
#'   repo directory.
#' @param org `[string]`\cr
#'   The organization of the new repository on GitHub, default: user namespace,
#'   no organization.
#' @param private `[flag]`\cr
#'   Must be `FALSE`, creation of private repositories not yet supported.
#' @param gh_token `[Token2.0]`\cr
#'   GitHub authentication token, by default obtained from [auth_github()] with
#'   the "public_repo" and (if an organization repo) "write:org" scopes.
#' @param quiet `[flag]`\cr
#'   Set to `FALSE` to suppress success message.
#'
#' @family GitHub functions
#'
#' @export
github_create_repo <- function(path = ".", name = NULL, org = NULL,
                               private = FALSE, gh_token = NULL, quiet = FALSE) {
  if (private) {
    stopc("Creating private repositories not supported.")
  }

  if (is.null(name)) {
    name <- basename(normalizePath(path))
  }

  data <- list(
    "name" = name
  )

  if (is.null(org)) {
    url <- "/user/repos"
    if (is.null(gh_token)) {
      gh_token <- auth_github("public_repo")
    }
  } else {
    url <- paste0("/orgs/", org, "/repos")
    if (is.null(gh_token)) {
      gh_token <- auth_github("public_repo", "write:org")
    }

    check_write_org(org, gh_token)
  }

  req <- GITHUB_POST(url, body = data, token = gh_token)
  check_status(req, sprintf("creat[ing]{e} GitHub repository %s", name), quiet)
  invisible(httr::content(req))
}
