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
#'
#' @family GitHub functions
github_info <- function(path = usethis::proj_get()) {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

get_repo_data <- function(repo) {
  message(sprintf("retrieve repo information for: '%s'", repo))
  req = gh::gh(sprintf("GET /repos/%s", repo))
  return(req)
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
