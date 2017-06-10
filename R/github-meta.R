#' @export
uses_github <- function(path = ".") {
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

#' Github Information
#'
#' Retrieves metadata about a git repository from github.
#'
#' @export
#' @param path directory of the git repository
#' @rdname github
github_info <- function(path = ".") {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

get_repo_data <- function(repo, token = NULL) {
  req <- GITHUB_GET(paste0("/repos/", repo), token = token)
  httr::stop_for_status(req, paste("retrieve repo information for: ", repo))
  httr::content(req)
}

#' @export
#' @rdname github
github_repo <- function(path = ".", info = github_info(path)) {
  paste(info$owner$login, info$name, sep = "/")
}
