get_remote_url <- function(path, remote) {
  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if (!length(remote_names)) {
    stopc("Failed to lookup git remotes")
  }
  remote_name <- remote
  if (!(remote_name %in% remote_names)) {
    stopc(sprintf(
      "No remote named '%s' found in remotes: '%s'.",
      remote_name, remote_names
    ))
  }
  git2r::remote_url(r, remote_name)
}

extract_repo <- function(url) {
  # Borrowed from gh:::github_remote_parse
  re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  m <- regexec(re, url)
  match <- regmatches(url, m)[[1]]

  if (length(match) == 0) {
    stopc("Unrecognized repo format: ", url)
  }

  paste0(match[2], "/", match[3])
}
