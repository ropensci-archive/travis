get_remote_url <- function(path) {
  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if (!length(remote_names))
    stop("Failed to lookup git remotes")
  remote_name <- "origin"
  if (!("origin" %in% remote_names)) {
    remote_name <- remote_names[1]
    warning("No remote 'origin' found. Using: ", remote_name)
  }
  git2r::remote_url(r, remote_name)
}
