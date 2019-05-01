#' Github information
#'
#' @description
#' Retrieves metadata about a Git repository from GitHub.
#'
#' `github_info()` returns a list as obtained from the GET "/repos/:repo" API.
#'
#' @export
#' @param path `[string]`\cr
#'   The path to a GitHub-enabled Git repository (or a subdirectory thereof).
#' @param gh_token `[Token2.0]`\cr
#'   GitHub authentication token, by default obtained from [auth_github()] with
#'   empty scope.
#'
#' @family GitHub functions
github_info <- function(path = usethis::proj_get(), gh_token = NULL) {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  if (is.null(gh_token)) {
    gh_token <- auth_github()
  }
  get_repo_data(repo, gh_token = gh_token)
}

get_repo_data <- function(repo, gh_token) {
  req <- GITHUB_GET(paste0("/repos/", repo), token = gh_token)
  httr::stop_for_status(req, paste0("retrieve repo information for: ", repo))
  httr::content(req)
}

#' @description
#' `github_repo()` returns the true repository name as string.
#'
#' @param info `[list]`\cr
#'   GitHub information for the repository, by default obtained through
#'   [github_info()].
#'
#' @export
#' @rdname github_info
github_repo <- function(path = usethis::proj_get(), info = github_info(path)) {
  paste(info$owner$login, info$name, sep = "/")
}

#' @description
#' `uses_github()` returns a flag that indicates if this repo is GitHub-enabled.
#' If `TRUE`, the "info" and "repo" attributes contain the results of the
#' corresponding functions. If `FALSE`, the "reason" attribute explains what
#' happened during detection of GitHub status.
#'
#' @export
#' @rdname github_info
uses_github <- function(path = usethis::proj_get()) {
  tryCatch(
    {
      info <- github_info(path)
      structure(TRUE, info = info, repo = github_repo(info = info))
    },
    error = function(e) {
      structure(FALSE, reason = conditionMessage(e))
    }
  )
}
