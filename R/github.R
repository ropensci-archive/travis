GITHUB_API <- "https://api.github.com"

#' Github Information
#'
#' Retrieves metadata about a git repository from github.
#'
#' @export
#' @param path directory of the git repository
github_info <- function(path = ".") {

  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if(!length(remote_names))
    stop("Failed to lookup git remotes")
  remote_name <- "origin"
  if(!("origin" %in% remote_names)){
    remote_name <- remote_names[1]
    warning("No remote 'origin' found. Using: ", remote_name)
  }
  remote_url <- git2r::remote_url(r, remote_name)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

get_repo_data <- function(repo){
  req <- httr::GET(paste0(GITHUB_API, "/repos/", repo))
  httr::stop_for_status(req, paste("retrieve repo information for: ", repo))
  jsonlite::fromJSON(httr::content(req, "text"))
}

extract_repo <- function(path){
  if(grepl("^git@github.com", path)){
    path <- sub("^git@github.com", "https://github.com", path)
  } else if(grepl("^http://github.com", path)){
    path <- sub("^http://github.com", "https://github.com", path)
  }
  if(!all(grepl("^https://github.com", path))){
    stop("Unrecognized repo format: ", path)
  }
  path <- sub("\\.git", "", path)
  sub("^https://github.com/", "", path)
}

auth_github <- function() {
  scopes <- c("repo", "read:org", "user:email", "write:repo_hook")
  app <- httr::oauth_app("github",
                         key = "4bca480fa14e7fb785a1",
                         secret = "70bb4da7bab3be6828808dd6ba37d19370b042d5")
  httr::oauth2.0_token(httr::oauth_endpoints("github"), app, scope = scopes)
}
