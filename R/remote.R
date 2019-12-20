get_remote_url <- function(path) {
  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if (!length(remote_names)) {
    stopc("Failed to lookup git remotes")
  }
  remote_name <- "origin"
  if (!("origin" %in% remote_names)) {
    remote_name <- remote_names[1]
    warningc("No remote 'origin' found. Using: ", remote_name)
  }
  git2r::remote_url(r, remote_name)
}

extract_repo <- function(url) {

  # account for ssh notation
  if (grepl("^git@github.com:", url)) {
    url <- sub("^git@github.com:", "https://github.com/", url)
  } else if (grepl("^git://github.com", url)) {
    url <- sub("^git://github.com:", "https://github.com/", url)
  }
  # account for "www"
    else if (grepl("^http://www.github.com", url)) {
    url <- sub("http://www.github.com", "https://github.com", url)
  } else if (grepl("^https://www.github.com", url)) {
    url <- sub("https://www.github.com", "https://github.com", url)
  }
  if (!all(grepl("^https://github.com", url))) {
    stopc("Unrecognized repo format: ", url)
  }
  # remove .git
  url <- sub("\\.git$", "", url)
  # remove https: prefix
  sub("^https://github.com/", "", url)
}
