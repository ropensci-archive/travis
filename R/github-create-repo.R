#' @export
github_create_repo <- function(path = ".", name = NULL, org = NULL, private = FALSE,
                               gh_token = NULL) {
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
      gh_token <- auth_github(scopes = "public_repo")
    }
  } else {
    url <- paste0("/orgs/", org, "/repos")
    if (is.null(gh_token)) {
      gh_token <- auth_github(scopes = c("public_repo", "write:org"))
    }

    check_write_org(org, gh_token)
  }

  req <- GITHUB_POST(url, body = data, token = gh_token)
  httr::stop_for_status(req, sprintf("create repo %s", name))
  invisible(httr::content(req))
}
